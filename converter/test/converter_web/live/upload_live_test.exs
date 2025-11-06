defmodule ConverterWeb.UploadLiveTest do
  use ConverterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Converter.FilesFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_upload(_) do
    upload = upload_fixture()
    %{upload: upload}
  end

  describe "Index" do
    setup [:create_upload]

    test "lists all uploads", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/uploads")

      assert html =~ "Listing Uploads"
    end

    test "saves new upload", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/uploads")

      assert index_live |> element("a", "New Upload") |> render_click() =~
               "New Upload"

      assert_patch(index_live, ~p"/uploads/new")

      assert index_live
             |> form("#upload-form", upload: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#upload-form", upload: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/uploads")

      html = render(index_live)
      assert html =~ "Upload created successfully"
    end

    test "updates upload in listing", %{conn: conn, upload: upload} do
      {:ok, index_live, _html} = live(conn, ~p"/uploads")

      assert index_live |> element("#uploads-#{upload.id} a", "Edit") |> render_click() =~
               "Edit Upload"

      assert_patch(index_live, ~p"/uploads/#{upload}/edit")

      assert index_live
             |> form("#upload-form", upload: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#upload-form", upload: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/uploads")

      html = render(index_live)
      assert html =~ "Upload updated successfully"
    end

    test "deletes upload in listing", %{conn: conn, upload: upload} do
      {:ok, index_live, _html} = live(conn, ~p"/uploads")

      assert index_live |> element("#uploads-#{upload.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#uploads-#{upload.id}")
    end
  end

  describe "Show" do
    setup [:create_upload]

    test "displays upload", %{conn: conn, upload: upload} do
      {:ok, _show_live, html} = live(conn, ~p"/uploads/#{upload}")

      assert html =~ "Show Upload"
    end

    test "updates upload within modal", %{conn: conn, upload: upload} do
      {:ok, show_live, _html} = live(conn, ~p"/uploads/#{upload}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Upload"

      assert_patch(show_live, ~p"/uploads/#{upload}/show/edit")

      assert show_live
             |> form("#upload-form", upload: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#upload-form", upload: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/uploads/#{upload}")

      html = render(show_live)
      assert html =~ "Upload updated successfully"
    end
  end
end
