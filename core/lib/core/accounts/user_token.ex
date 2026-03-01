defmodule Core.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  alias Core.Accounts.UserToken

  @hash_algorithm :sha256
  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.
  @reset_password_validity_in_days 1
  @confirm_validity_in_days 7
  @change_email_validity_in_days 7
  @session_validity_in_days 60

  schema "users_tokens" do
    field :token,         :binary
    field :context,       :string
    field :sent_to,       :string
    field :access_token,  :string
    field :refresh_token, :string
    field :expires_at,    :utc_datetime
    field :provider,      :string
    field :provider_uid,  :string

    belongs_to :user, Core.Accounts.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix' default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual user
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %UserToken{token: token, context: "session", user_id: user.id}}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  def verify_session_token_query(token) do
    query =
      from token in by_token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: user

    {:ok, query}
  end

  @doc """
  Builds a token and its hash to be delivered to the user's email.

  The non-hashed token is sent to the user email while the
  hashed part is stored in the database. The original token cannot be reconstructed,
  which means anyone with read-only access to the database cannot directly use
  the token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  Users can easily adapt the existing code to provide other types of delivery methods,
  for example, by phone numbers.
  """
  def build_email_token(user, context) do
    build_hashed_token(user, context, user.email)
  end

  defp build_hashed_token(user, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %UserToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       user_id: user.id
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The given token is valid if it matches its hashed counterpart in the
  database and the user email has not changed. This function also checks
  if the token is being used within a certain period, depending on the
  context. The default contexts supported by this function are either
  "confirm", for account confirmation emails, and "reset_password",
  for resetting the password. For verifying requests to change the email,
  see `verify_change_email_token_query/2`.
  """
  def verify_email_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            join: user in assoc(token, :user),
            where: token.inserted_at > ago(^days, "day") and token.sent_to == user.email,
            select: user

        {:ok, query}

      :error ->
        :error
    end
  end

  defp days_for_context("confirm"), do: @confirm_validity_in_days
  defp days_for_context("reset_password"), do: @reset_password_validity_in_days

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  This is used to validate requests to change the user
  email. It is different from `verify_email_token_query/2` precisely because
  `verify_email_token_query/2` validates the email has not changed, which is
  the starting point by this function.

  The given token is valid if it matches its hashed counterpart in the
  database and if it has not expired (after @change_email_validity_in_days).
  The context must always start with "change:".
  """
  def verify_change_email_token_query(token, "change:" <> _ = context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(@change_email_validity_in_days, "day")

        {:ok, query}

      :error ->
        :error
    end
  end

  def build_oauth_token(user, auth) do
    credentials = auth.credentials
    provider    = to_string(auth.provider)

    {raw_token, hashed_token} = build_raw_and_hashed_token()

    token_struct = %UserToken{
      token:         hashed_token,
      context:       oauth_context(provider),
      provider:      provider,
      provider_uid:  to_string(auth.uid),
      access_token:  credentials.token,
      refresh_token: credentials.refresh_token,
      expires_at:    parse_unix_expires_at(credentials.expires_at),
      user_id:       user.id
    }

    {raw_token, token_struct}
  end

  def refresh_oauth_token_changeset(token_struct, new_credentials) do
    token_struct
    |> change(%{
      access_token: new_credentials.token,
      expires_at:   parse_unix_expires_at(new_credentials.expires_at)
    })
    |> validate_required([:access_token])
  end

  def token_expired?(%UserToken{expires_at: nil}), do: false

  def token_expired?(%UserToken{expires_at: expires_at}) do
    DateTime.compare(DateTime.utc_now(), expires_at) == :gt
  end

  @doc """
  Returns the token struct for the given token value and context.
  """
  def by_token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end

  @doc """
  Gets all tokens for the given user for the given contexts.
  """
  def by_user_and_contexts_query(user, :all) do
    from t in UserToken, where: t.user_id == ^user.id
  end

  def by_user_and_contexts_query(user, [_ | _] = contexts) do
    from t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts
  end

  def by_user_and_provider_query(user, provider) do
    from t in UserToken,
      where: t.user_id == ^user.id and t.context == ^oauth_context(provider)
  end

  def all_oauth_tokens_query(user) do
    from t in UserToken,
      where: t.user_id == ^user.id and like(t.context, "oauth:%")
  end

  # Generates a cryptographically random token and its SHA-256 hash.
  # Returns {url_safe_base64_raw, hashed_binary}.
  defp build_raw_and_hashed_token do
    raw    = :crypto.strong_rand_bytes(@rand_size)
    hashed = :crypto.hash(@hash_algorithm, raw)
    {Base.url_encode64(raw, padding: false), hashed}
  end

  # Safely converts a Unix timestamp integer to a truncated UTC DateTime,
  # returning nil when the provider does not supply an expiry.
  defp parse_unix_expires_at(nil), do: nil

  defp parse_unix_expires_at(unix_time) do
    unix_time
    |> DateTime.from_unix!()
    |> DateTime.truncate(:second)
  end

  defp oauth_context(provider), do: "oauth:#{provider}"

end
