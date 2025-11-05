defmodule ConvertUiWeb.BatchLiveTest do
  use ConvertUiWeb.ConnCase

  import Phoenix.LiveViewTest
  import ConvertUi.DocsFixtures

  @create_attrs %{name: "some name", description: "some description"}
  @update_attrs %{name: "some updated name", description: "some updated description"}
  @invalid_attrs %{name: nil, description: nil}

  defp create_batch(_) do
    batch = batch_fixture()
    %{batch: batch}
  end

  describe "Index" do
    setup [:create_batch]

    test "lists all batches", %{conn: conn, batch: batch} do
      {:ok, _index_live, html} = live(conn, ~p"/batches")

      assert html =~ "Listing Batches"
      assert html =~ batch.name
    end

    test "saves new batch", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/batches")

      assert index_live |> element("a", "New Batch") |> render_click() =~
               "New Batch"

      assert_patch(index_live, ~p"/batches/new")

      assert index_live
             |> form("#batch-form", batch: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#batch-form", batch: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/batches")

      html = render(index_live)
      assert html =~ "Batch created successfully"
      assert html =~ "some name"
    end

    test "updates batch in listing", %{conn: conn, batch: batch} do
      {:ok, index_live, _html} = live(conn, ~p"/batches")

      assert index_live |> element("#batches-#{batch.id} a", "Edit") |> render_click() =~
               "Edit Batch"

      assert_patch(index_live, ~p"/batches/#{batch}/edit")

      assert index_live
             |> form("#batch-form", batch: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#batch-form", batch: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/batches")

      html = render(index_live)
      assert html =~ "Batch updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes batch in listing", %{conn: conn, batch: batch} do
      {:ok, index_live, _html} = live(conn, ~p"/batches")

      assert index_live |> element("#batches-#{batch.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#batches-#{batch.id}")
    end
  end

  describe "Show" do
    setup [:create_batch]

    test "displays batch", %{conn: conn, batch: batch} do
      {:ok, _show_live, html} = live(conn, ~p"/batches/#{batch}")

      assert html =~ "Show Batch"
      assert html =~ batch.name
    end

    test "updates batch within modal", %{conn: conn, batch: batch} do
      {:ok, show_live, _html} = live(conn, ~p"/batches/#{batch}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Batch"

      assert_patch(show_live, ~p"/batches/#{batch}/show/edit")

      assert show_live
             |> form("#batch-form", batch: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#batch-form", batch: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/batches/#{batch}")

      html = render(show_live)
      assert html =~ "Batch updated successfully"
      assert html =~ "some updated name"
    end
  end
end
