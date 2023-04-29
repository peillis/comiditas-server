
let hideSelector = () => {
  setTimeout(() => {
    document.getElementById('selector').style.display = 'none'
  }, 100)
}
let showSelector = {
  mounted() {
    this.el.addEventListener('click', e => {
      // Find the TD closest to the event to get its coordinates
      td_parent = e.target
      if (td_parent.tagName != 'TD') {
        td_parent = td_parent.closest('.buttons')
      }
      rect = td_parent.lastElementChild.getBoundingClientRect()
      td_parent.dataset.left = rect.left - 53
      td_parent.dataset.top = rect.top - 44
      this.pushEvent('select', td_parent.dataset)
    })
  }
}

export let Hooks = {}

switch (window.location.pathname) {
  case '/app/list':
    Hooks.TableHook = {
      mounted() {
        let scrollfn = (ev) => {
          if ((window.innerHeight + window.scrollY + 50) >= document.body.offsetHeight) {
            this.pushEvent('view_more', null)
          }
          hideSelector()
        }
        window.onscroll = scrollfn
      }
    }
    Hooks.ShowSelector = showSelector;

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
    Hooks.ShowSelector = showSelector;
    window.onscroll = hideSelector;
    break
}
