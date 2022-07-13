let showSelector = (node, date, meal) => {
  let selector = document.getElementById('selector')
  let rect = node.getBoundingClientRect()
  let buttons = selector.children
  for (let b of buttons) {
    b.setAttribute('phx-value-date', date)
    b.setAttribute('phx-value-meal', meal)
  }
  selector.style.top = `${rect.top - 44}px`
  selector.style.left = `${rect.left - 53}px`
  selector.style.display = 'inline-block'
}

let showSelectorMultiSelect = (node_from, node_to) => {
  let selector = document.getElementById('selector')
  let rect = node_to.getBoundingClientRect()
  let buttons = selector.children
  for (let b of buttons) {
    b.setAttribute('phx-value-date-from', node_from.dataset.date)
    b.setAttribute('phx-value-meal-from', node_from.dataset.meal)
    b.setAttribute('phx-value-date-to', node_to.dataset.date)
    b.setAttribute('phx-value-meal-to', node_to.dataset.meal)
  }
  selector.style.top = `${rect.top - 44}px`
  selector.style.left = `${rect.left - 53}px`
  selector.style.display = 'inline-block'
}

let hideSelector = () => {
  setTimeout(() => {
    let selector = document.getElementById('selector')
    selector.style.display = 'none'
  }, 100)
}

let select = (event) => {
  let parent = event.target
  if (event.target.tagName != "TD") {
    parent = event.target.closest('.buttons')
  }
  if (parent.classList.contains('frozen')) {
    return
  }
  let elem = parent.lastElementChild
  if (document.getElementsByClassName('blink').length > 0){
    // multi select
    let from_elem = document.getElementsByClassName('blink')[0]
    if (elem.dataset.date < from_elem.dataset.date){
      return
    } 
    from_elem.classList.remove('blink')
    let next = from_elem
    while(next != elem) {
      next.classList.add('blink')
      next = next_button(next)
    }
    showSelectorMultiSelect(from_elem, elem)
  }
  else {
    let date = elem.dataset.date
    let meal = elem.dataset.meal
    showSelector(elem, date, meal)
  }
}

let next_button = (elem) => {
  let td = elem.parentElement
  if (td.nextElementSibling != null) {
    if (td.nextElementSibling.className == 'buttons'){
      return td.nextElementSibling.firstElementChild
    }
    else {
      let td_of_next_tr = td.parentElement.nextElementSibling.children[1]
      return td_of_next_tr.firstElementChild
    }
  }
  else {
    let td_of_next_tr = td.parentElement.nextElementSibling.children[1]
    return td_of_next_tr.firstElementChild
  }
}

let addClickListener = (elems, fn) => {
  for (let e of elems) {
    e.addEventListener('click', fn)
  }
}

let activateButtons = () => {
  let buttons = document.getElementsByClassName('buttons')
  addClickListener(buttons, select)
  let selector_buttons = document.getElementById('selector').children
  addClickListener(selector_buttons, hideSelector)
}

export let Hooks = {}

switch (window.location.pathname) {
  case '/app/list':
    Hooks.TableHook = {
      updated() {
        activateActions()
      },
      mounted() {
        activateActions()
        let modal_bck = document.getElementById('modal-background')
        modal_bck.addEventListener('click', hideModal)
        let scrollfn = (ev) => {
          if ((window.innerHeight + window.scrollY + 50) >= document.body.offsetHeight) {
            this.pushEvent('view_more', null)
          }
          hideSelector()
        }
        window.onscroll = scrollfn
      }
    }

    let activateActions = () => {
      activateButtons()
      let notes = document.getElementsByClassName('notes')
      addClickListener(notes, showModal)
    }

    let showModal = (event) => {
      let elem = event.target
      if (elem.tagName == "I") elem = elem.parentNode
      if (elem.classList.contains('frozen')) {
        return
      }
      let modal = document.getElementById('modal')
      let modal_bck = document.getElementById('modal-background')
      let notes = document.getElementById('notes')
      let date = document.getElementById('date')
      notes.value = elem.dataset.notes
      date.value = elem.dataset.date
      modal.style.display = 'block'
      modal_bck.style.display = 'block'
      notes.focus()
    }

    let hideModal = () => {
      let modal = document.getElementById('modal')
      let modal_bck = document.getElementById('modal-background')
      modal.style.display = 'none'
      modal_bck.style.display = 'none'
    }
    break

  case '/app/totals':
    Hooks.TableHook = {
      mounted() {
        var hammertime = new Hammer(document.body);
        let change_day = (ev) => {
          if (ev.offsetDirection == 2) {  // swipe to left
            this.pushEvent('change_date', 1)
          }
          if (ev.offsetDirection == 4) {  // to right
            this.pushEvent('change_date', -1)
          }
        }
        hammertime.on('swipe', change_day)
      }
    }
    break

  case '/app/settings':
    Hooks.TableHook = {
      updated() {
        activateButtons()
      }
    }

    window.onscroll = function(ev) {
      hideSelector()
    };
    break
}
