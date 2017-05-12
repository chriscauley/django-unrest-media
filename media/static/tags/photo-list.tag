uR.ready(function() {
  function dropHandler(e) {
    e.preventDefault();
    var tag = this;
    tag.root.querySelector("photo-list .rows").classList.add("loading");

    var files = e.dataTransfer.files;

    var formData = new FormData();
    for (var i = 0; i < files.length; i++) {
      formData.append('file', files[i]);
    }
    formData.append('content_type',window._PHOTOS.content_type);
    formData.append('object_id',window._PHOTOS.object_id);
    var csrf_token = $('[name=csrfmiddlewaretoken]').val();
    formData.append('csrfmiddlewaretoken', csrf_token);

    var xhr = new XMLHttpRequest();
    var post_url = "/media_files/photo/bulk_upload/";
    xhr.open('POST', post_url);
    xhr.onload = function () {
      var i;
      var text = this.responseText;
      if (xhr.status === 200) {
        var new_photos = JSON.parse(xhr.responseText);
        var i = new_photos.length;
        uR.forEach(new_photos,function(photo) { window._PHOTOS.photos.push(photo); });
        tag.update();
        tag.root.querySelector("photo-list .rows").classList.remove("loading");
      } else {
        alert("An unknown error has occurred, go bug Chris");
      }
    };
    // Here's where the form, with photos attached, is actually posted:
    xhr.send(formData);
  }

  riot.mount("photo-list",{dropHandler:dropHandler});
  riot.mount('photo-search',{});
});

<photo-list>
  <b>What is the difference between "delete" and "unlink"? Delete removes it from the database. In general only delete if it is a photo you just added and want to replace it with an updated photo</b>
  <div class="rows">
    <div id="dropzone" class="fourth dropzone"></div>
    <photo class="fourth { removed?'removed':'' }" each={ photos } id="__photo_{ id }" if={ !deleted }>
      <div class="buttons upper">
        <button class="btn btn-danger" onclick={ parent.untag } title="Will not delete photo from database"
                if={ !removed }><i class="fa fa-times"></i> Unlink</button>
        <button class="btn btn-danger" onclick={ parent.delete } title="Will delete from database">
          <i class="fa fa-warning"></i> Delete</button>
        <a class="btn btn-primary" href="/admin/media/photo/{ id }/">
          <i class="fa fa-pencil-square"></i> Edit</a>
      </div>
      <div class="buttons lower">
        <button class="btn btn-warning fa fa-arrow-circle-left" value="-1" onclick={ orderIt }></button>
        <button class="btn btn-warning fa fa-arrow-circle-right" value="1" onclick={ orderIt }></button>
      </div>
      <img src="{ thumbnail }" if={ thumbnail }/>
      <div data-error={ error } if={ error }></div>
      <div class="name" contenteditable="true" onkeyup={ parent.editName }>{ name }</div>
    </photo>
  </div>

  this.photos = window._PHOTOS.photos;
  var self = this;
  var edit_timeout;
  this.on("mount",function() {
    var dz = this.root.querySelector("#dropzone");
    dz.addEventListener("dragenter", function(e) {
      e.preventDefault();
      e.target.classList.remove("hover");
    })
    dz.addEventListener("dragleave", function(e) {
      e.preventDefault();
      e.target.classList.remove("hover");
    })
    dz.addEventListener("dragover", function(e) { e.preventDefault(); });
    dz.addEventListener("drop", opts.dropHandler.bind(this));
  });
  this.editName = uR.debounce(function(e) {
    uR.ajax({
      url: '/media_files/photo/edit/'+e.item.id+'/',
      data: {name:e.target.innerText},
      target: self.root.querySelector("#__photo_"+e.item.id),
      loading_attribute: "background-spinner",
    });
  },200);

  untag(e) {
    uR.ajax({
      url: '/media_files/photo/untag/',
      method: "POST",
      data: {
        content_type:window._PHOTOS.content_type,
        object_id:window._PHOTOS.object_id,
        photo_id: e.item.id
      },
      that: self,
      target: self.root.querySelector("#__photo_"+e.item.id),
      success: function(data) { e.item.removed = true; }
    });
  }
  delete(e) {
    var warn = "This will delete this photo entirely from the site. Don't do this unless you are certain.";
    warn += "\n\nTo bypass this message next time, hold down the control key when you click the delete button.";
    if (e.ctrlKey || confirm(warn)) {
      uR.ajax({
        url: '/media_files/photo/delete/'+e.item.id+'/',
        method: "POST",
        that: self,
        target: self.root.querySelector("#__photo_"+e.item.id),
        success: function(data) { e.item.deleted = true; }
      });
    }
  }
  orderIt(e) {
    this.ajax({
      url: '/media_files/photo/order/',
      method: "POST",
      data: {
        move: e.target.value,
        content_type:window._PHOTOS.content_type,
        object_id:window._PHOTOS.object_id,
        photo_id: e.item.id
      },
      target: this.root,
      success: function(data) { this.photos = data.photos; this.update },
    });
  }
</photo-list>

<photo-search>
  <form onsubmit={ search }>
    <input name="q" onkeyup={ search }>
    <div class="search_results rows">
      <div onclick={ parent.select } each={ search_results } class="fourth btn btn-primary">
        <img src="{ thumbnail }" />
        <div class="name">{ name }</div>
      </div>
    </div>
  </div>

  var self = this;
  var search_timeout;
  search(e) {
    clearTimeout(search_timeout);
    var q = self.q.value;
    if (!q || q.length < 3) { return }
    search_timeout = setTimeout(function() {
      $.get(
        "/media_files/photo/search/",
        {q:self.q.value},
        function(data) {
          self.search_results = data;
          self.update();
        },
        "json"
      )
    },200);
    return true;
  }
  select(e) {
    $.get(
      "/media_files/photo/tag/",
      {
        content_type:window._PHOTOS.content_type,
        object_id:window._PHOTOS.object_id,
        photo_id: e.item.id
      },
      function(data) {
        self.search_results = [];
        self.update();
        if (data) { //data is true/false depending on whether or not a tag was created
          window._PHOTOS.photos.unshift(e.item);
          riot.update("photo-list");
        }
      }
    )
  }
</photo-search>
