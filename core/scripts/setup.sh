#! /bin/bash
mix ecto.create
mix ecto.migrate

mix phx.gen.auth Accounts User users
mix phx.gen.live Uploads Batch batches status:string user_id:references:user --binary-id
mix phx.gen.context Items Picture pictures  batch_id:references:batch name:string transform:string size:integer --binary-id