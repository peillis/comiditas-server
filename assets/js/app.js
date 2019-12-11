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

let liveSocket = new LiveSocket("/live", Socket, {viewLogger: debug})
liveSocket.connect()

window.liveSocket = liveSocket;

let change = () => {
    let layer = document.getElementsByClassName('main')[0].parentElement
    let view = liveSocket.views[layer.id]
    view.channel.push('event', {
        event: 'my_test',
        type: null,
        value: 3
    }, 20000).receive("ok", resp => { view.update(resp.diff) })
}
window.change = change

window.onscroll = function(ev) {
    if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight) {
        console.log('hey')
        change()
    }
};