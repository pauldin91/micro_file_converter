#! /bin/bash

mix phx.gen.live Pictures Picture pictures guid:string name:string timestamp:utc_datetime status:string
mix phx.gen.live Transformers Transform transforms picture_id:references:pictures guid:string type:string exec:boolean 