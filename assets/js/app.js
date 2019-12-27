// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import {Socket} from "phoenix"
import {LiveSocket, debug} from "phoenix_live_view"

let Hooks = {}

// Triggers an event on liveview
let send_event = (event_name, value) => {
    let layer = document.getElementsByClassName('main')[0].parentElement
    let view = liveSocket.views[layer.id]
    view.channel.push('event', {
        event: event_name,
        type: null,
        value: value
    }, 5000).receive("ok", resp => { view.update(resp.diff) })
}

switch (window.location.pathname) {
    case '/list':
        Hooks.TableHook = {
            updated() {
                let buttons = document.getElementsByClassName('buttons')
                for (let b of buttons) {
                    b.addEventListener('click', select)
                }
            }
        }

        let showSelector = (node, date, meal) => {
            let selector = document.getElementById('selector')
            let rect = node.getBoundingClientRect()
            let buttons = selector.children
            for (let b of buttons) {
                b.setAttribute('phx-value-date', date)
                b.setAttribute('phx-value-meal', meal)
            }
            selector.style.top = rect.top
            selector.style.left = rect.left
            selector.style.display = 'inline-block'
        }

        let hideSelector = () => {
            let selector = document.getElementById('selector')
            selector.style.display = 'none'
        }

        let select = (event) => {
            let elem = event.target.parentNode
            let date = elem.dataset.date
            let meal = elem.dataset.meal
            showSelector(elem, date, meal)
        }


        window.onscroll = function(ev) {
            if ((window.innerHeight + window.scrollY + 50) >= document.body.offsetHeight) {
                send_event('view_more', null)
            }
            hideSelector()
        };
    
    case '/totals':
        var hammertime = new Hammer(document.body);
        hammertime.on('swipe', function(ev) {
            if (ev.offsetDirection == 2) {  // swipe to left
                send_event('change_date', 1)
            }
            if (ev.offsetDirection == 4) {  // to right
                send_event('change_date', -1)
            }
        });
}

let liveSocket = new LiveSocket("/live", Socket, {viewLogger: debug, hooks: Hooks})
liveSocket.connect()
