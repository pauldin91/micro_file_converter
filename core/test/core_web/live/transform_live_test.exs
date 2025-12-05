defmodule CoreWeb.TransformLiveTest do
  use CoreWeb.ConnCase

  import Phoenix.LiveViewTest
  import Core.TransformersFixtures

  @create_attrs %{type: "some type", exec: true, guid: "some guid"}
  @update_attrs %{type: "some updated type", exec: false, guid: "some updated guid"}
  @invalid_attrs %{type: nil, exec: false, guid: nil}

  defp create_transform(_) do
    transform = transform_fixture()
    %{transform: transform}
  end

  describe "Index" do
    setup [:create_transform]

    test "lists all transforms", %{conn: conn, transform: transform} do
      {:ok, _index_live, html} = live(conn, ~p"/transforms")

      assert html =~ "Listing Transforms"
      assert html =~ transform.type
    end

    test "saves new transform", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/transforms")

      assert index_live |> element("a", "New Transform") |> render_click() =~
               "New Transform"

      assert_patch(index_live, ~p"/transforms/new")

      assert index_live
             |> form("#transform-form", transform: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#transform-form", transform: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/transforms")

      html = render(index_live)
      assert html =~ "Transform created successfully"
      assert html =~ "some type"
    end

    test "updates transform in listing", %{conn: conn, transform: transform} do
      {:ok, index_live, _html} = live(conn, ~p"/transforms")

      assert index_live |> element("#transforms-#{transform.id} a", "Edit") |> render_click() =~
               "Edit Transform"

      assert_patch(index_live, ~p"/transforms/#{transform}/edit")

      assert index_live
             |> form("#transform-form", transform: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#transform-form", transform: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/transforms")

      html = render(index_live)
      assert html =~ "Transform updated successfully"
      assert html =~ "some updated type"
    end

    test "deletes transform in listing", %{conn: conn, transform: transform} do
      {:ok, index_live, _html} = live(conn, ~p"/transforms")

      assert index_live |> element("#transforms-#{transform.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#transforms-#{transform.id}")
    end
  end

  describe "Show" do
    setup [:create_transform]

    test "displays transform", %{conn: conn, transform: transform} do
      {:ok, _show_live, html} = live(conn, ~p"/transforms/#{transform}")

      assert html =~ "Show Transform"
      assert html =~ transform.type
    end

    test "updates transform within modal", %{conn: conn, transform: transform} do
      {:ok, show_live, _html} = live(conn, ~p"/transforms/#{transform}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Transform"

      assert_patch(show_live, ~p"/transforms/#{transform}/show/edit")

      assert show_live
             |> form("#transform-form", transform: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#transform-form", transform: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/transforms/#{transform}")

      html = render(show_live)
      assert html =~ "Transform updated successfully"
      assert html =~ "some updated type"
    end
  end
end
