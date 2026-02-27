defmodule CoreWeb.AuthController do
  use CoreWeb, :controller
  plug(Ueberauth)

  alias Core.Accounts.User
  alias Core.Repo

  def callback(%{assigns: %{ueberauth_failure: %Ueberauth.Failure{}}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{} = auth}} = conn, _params) do
    user_params = %{token: auth.credentials.token, email: auth.info.nickname, provider: "github"}

    changeset = User.changeset(%User{}, user_params)

    signin(conn, changeset)
  end

  defp signin(conn, changeset) do
    case(insert_or_update_user(changeset)) do
      {:ok, user} ->
        token = Phoenix.Token.sign(conn, "key", user.id)

        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)
        |> assign(:user_token, token)
        |> redirect(to: ~p"/")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error sigining in")
        |> redirect(to: ~p"/")
    end
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: ~p"/")
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil -> Repo.insert(changeset)
      user -> {:ok, user}
    end
  end
end
