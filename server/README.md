# server

## Development

build the client
```sh
cd ../client
gleam run -m lustre/dev build --outdir=../server/priv/static --minify
```

Note: If you have made changes to the client or shared directories, remember to run `gleam update`.

run the server
```sh
cd ../server
gleam run [--host {host}, --port {port}] # Run the project
```
