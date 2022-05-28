@module external styles: {..} = "./app.module.css"
type item = {
  id: string,
  text: string,
}

module Add = {
  open React
  open ReactEvent
  @react.component
  let make = (~add, ~text=?) => {
    let text = switch text {
    | None => ""
    | Some(x) => x
    }
    let (value, setValue) = useState(_ => text)
    let submit = _ => {
      add(value)
    }
    let onChange = evt => {
      let value = Form.target(evt)["value"]
      setValue(_ => value)
    }
    <div className={styles["add"]}>
      <input className={styles["input"]} value onChange />
      <button className={styles["btn"]} onClick={_ => submit()}> {`添加`->React.string} </button>
    </div>
  }
}

@val @scope("document")
external createElement: string => Dom.element = "createElement"
@set
external setId: (Dom.element, string) => unit = "id"
@val @scope(("document", "body"))
external appendToBody: Dom.element => unit = "append"

module Modal = {
  open ReactDOM
  @react.component
  let make = (~visible, ~children) => {
    let wrapper =
      <div className={styles["mask"]}> <div className={styles["modal"]}> children </div> </div>
    switch visible {
    | false => React.null
    | true =>
      switch querySelector("#modal") {
      | Some(root) => createPortal(wrapper, root)
      | None => {
          let element = createElement("div")
          setId(element, "modal")
          appendToBody(element)
          createPortal(wrapper, element)
        }
      }
    }
  }
}

module Input = {
  @react.component
  let make = (~value, ~onChange=?) => {
    switch onChange {
    | None => <input value className={styles["input"]} />
    | Some(onChange) => <input onChange value className={styles["input"]} />
    }
  }
}

module Button = {
  @react.component
  let make = (~children, ~onClick) => {
    <button className={styles["btn"]} onClick> children </button>
  }
}

module Update = {
  open React
  @react.component
  let make = (~id, ~text, ~setTodos) => {
    let (visible, setVisible) = useState(_ => false)
    let (text, setText) = useState(_ => text)
    let onChange = evt => {
      let value = ReactEvent.Form.target(evt)["value"]
      setText(_ => value)
    }

    let submit = () => {
      Js.log(text)
      Js.log(id)
      setTodos(prev => {
        prev->Belt.Array.map(v => {
          switch id == v.id {
          | false => v
          | true => {id: id, text: text}
          }
        })
      })
      setVisible(_ => false)
    }
    <>
      <Button onClick={_ => setVisible(_ => true)}> {`更新`->React.string} </Button>
      <Modal visible>
        <Input value={text} onChange />
        <Button onClick={_ => submit()}> {`提交`->React.string} </Button>
      </Modal>
    </>
  }
}
module List = {
  @react.component
  let make = (~todos, ~setTodos) =>
    <div className={styles["list"]}>
      {todos
      ->Belt.Array.map(v => {
        let {id, text} = v
        <div key={id} className={styles["item"]}>
          <span className={styles["text"]}> {text->React.string} </span>
          <span className={styles["btnGroup"]}>
            <Update text id setTodos />
            <span className={styles["del"]}> {`删除`->React.string} </span>
          </span>
        </div>
      })
      ->React.array}
    </div>
}

@react.component
let make = () => {
  open React
  let (todos, setTodos) = useState(_ => [])
  let add = text => {
    let id = Js.Math.random_int(1, 10000000)->Js.Int.toString
    let result = Js.Array2.concat(todos, [{id: id, text: text}])
    setTodos(_ => result)
  }
  <div> <Add add /> <List todos setTodos /> </div>
}
