cd ./client
gleam run -m lustre/dev build --outdir=../server/priv/static --minify
cd ../server
gleam run
