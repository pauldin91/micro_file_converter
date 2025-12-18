#! /bin/bash

mix phx.gen.auth
mix phx.gen.live Uploads Batch batches status:string --binary-id
mix phx.gen.live Items Picture pictures  batch_id:references:batch name:string transform:string size:integer --binary-id