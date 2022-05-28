open ReactDOM

switch querySelector("#root") {
| None => ()
| Some(root) => render(<App />, root)
}
