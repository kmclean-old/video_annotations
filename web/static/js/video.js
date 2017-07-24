import Player from "./player"

let Video = {
  init(socket, element) { if (!element) { return }
    let playerId = element.getAttribute("data-player-id")
    let videoId = element.getAttribute("data-id")
    socket.connect()
    Player.init(element.id, playerId, () => {
      this.onReady(videoId, socket)
    })
  },

  onReady(videoId, socket) {
    let msgContainer = document.getElementById("msg-container")
    let msgInput = document.getElementById("msg-input")
    let postButton = document.getElementById("msg-submit")
    let vidChannel = socket.channel(`videos:${videoId}`)

    vidChannel.on("ping", ({count}) => console.log("PING", count))

    postButton.addEventListener("click", e => {
      let payload = {body: msgInput.value, at: Player.getCurrentTime()}
      vidChannel.push("new_annotation", payload)
        .receive("error", e => console.log(e))
      msgInput.value = ""
    })

    vidChannel.on("new_annotation", (response) => {
      vidChannel.params.last_seen_id = response.id
      this.renderAnnotation(msgContainer, response)
    })

    msgContainer.addEventListener("click", event => {
      event.preventDefault()
      let seconds = event.target.getAttribute("data-seek") ||
        event.target.parentNode.getAttribute("data-seek")

      if(!seconds) { return }

      Player.seekTo(seconds)
    })

    vidChannel.join()
      .receive("ok", response => {
        let ids = response.annotations.map(annotation => annotation.id)
        if(ids.length > 0) { vidChannel.params.last_seen_id = Math.max(...ids) }
        this.scheduleMessages(msgContainer, response.annotations)
      })
      .receive("error", reason => console.log("join failed", reason))
  },

  esc(string) {
    let div = document.createElement("div")
    div.appendChild(document.createTextNode(string))
    return div.innerHTML
  },

  renderAnnotation(msgContainer, {user, body, at}) {
    let template = document.createElement("div")
    template.innerHTML = `
      <a href="#" data-seek="${this.esc(at)}">
        [${this.formatTime(at)}]
        <b>${this.esc(user.username)}</b>: ${this.esc(body)}
      </a>
    `

    msgContainer.appendChild(template)
    msgContainer.scrollTop = msgContainer.scrollHeight
  },

  scheduleMessages(msgContainer, annotations) {
    setTimeout(() => {
      let ctime = Player.getCurrentTime()
      let remaining = this.renderAtTime(annotations, ctime, msgContainer)
      this.scheduleMessages(msgContainer, remaining)
    }, 1000)
  },

  renderAtTime(annotations, seconds, msgContainer) {
    return annotations.filter(annotation => {
      if(annotation.at > seconds) {
        return true
      } else {
        this.renderAnnotation(msgContainer, annotation)
        return false
      }
    })
  },

  formatTime(at) {
    let date = new Date(null)
    date.setSeconds(at / 1000)
    return date.toISOString().substr(14, 5)
  }
}

export default Video
