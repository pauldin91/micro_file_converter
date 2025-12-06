defmodule CoreWeb.PictureLiveTest do
  use CoreWeb.ConnCase

  import Phoenix.LiveViewTest
  import Core.UploadsFixtures

  @create_attrs %{name: "some name", size: 42, status: "some status"}
  @update_attrs %{name: "some updated name", size: 43, status: "some updated status"}
  @invalid_attrs %{name: nil, size: nil, status: nil}

  defp create_picture(_) do
    picture = picture_fixture()
    %{picture: picture}
  end

  describe "Index" do
    setup [:create_picture]

    test "lists all pictures", %{conn: conn, picture: picture} do
      {:ok, _index_live, html} = live(conn, ~p"/pictures")

      assert html =~ "Listing Pictures"
      assert html =~ picture.name
    end

    test "saves new picture", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/pictures")

      assert index_live |> element("a", "New Picture") |> render_click() =~
               "New Picture"

      assert_patch(index_live, ~p"/pictures/new")

      assert index_live
             |> form("#picture-form", picture: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#picture-form", picture: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/pictures")

      html = render(index_live)
      assert html =~ "Picture created successfully"
      assert html =~ "some name"
    end

    test "updates picture in listing", %{conn: conn, picture: picture} do
      {:ok, index_live, _html} = live(conn, ~p"/pictures")

      assert index_live |> element("#pictures-#{picture.id} a", "Edit") |> render_click() =~
               "Edit Picture"

      assert_patch(index_live, ~p"/pictures/#{picture}/edit")

      assert index_live
             |> form("#picture-form", picture: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#picture-form", picture: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/pictures")

      html = render(index_live)
      assert html =~ "Picture updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes picture in listing", %{conn: conn, picture: picture} do
      {:ok, index_live, _html} = live(conn, ~p"/pictures")

      assert index_live |> element("#pictures-#{picture.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#pictures-#{picture.id}")
    end
  end

  describe "Show" do
    setup [:create_picture]

    test "displays picture", %{conn: conn, picture: picture} do
      {:ok, _show_live, html} = live(conn, ~p"/pictures/#{picture}")

      assert html =~ "Show Picture"
      assert html =~ picture.name
    end

    test "updates picture within modal", %{conn: conn, picture: picture} do
      {:ok, show_live, _html} = live(conn, ~p"/pictures/#{picture}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Picture"

      assert_patch(show_live, ~p"/pictures/#{picture}/show/edit")

      assert show_live
             |> form("#picture-form", picture: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#picture-form", picture: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/pictures/#{picture}")

      html = render(show_live)
      assert html =~ "Picture updated successfully"
      assert html =~ "some updated name"
    end
  end
end
