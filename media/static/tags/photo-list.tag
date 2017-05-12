<photo-list>
  <div class="rows">
    <div id="dropzone" class="fourth dropzone"></div>
    <photo class="fourth { removed?'removed':'' }" each={ photos } id="__photo_{ id }" if={ !deleted }>
      <div class="buttons">
        <button class="btn btn-danger" onclick={ parent.untag } title="Will not delete photo from database"
                if={ !removed }><i class="fa fa-times"></i> Unlink</button>
        <button class="btn btn-danger" onclick={ parent.delete } title="Will delete from database">
          <i class="fa fa-warning"></i> Delete</button>
        <a class="btn btn-primary" href="/admin/media/photo/{ id }/">
          <i class="fa fa-pencil-square"></i> Edit</a>
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
    $("#dropzone").bind("dragenter", function(e) {
      e.preventDefault();
      $(e.target).addClass("hover");
    }).bind("dragleave", function(e) {
      e.preventDefault();
      $(e.target).removeClass("hover");
    }).bind("dragover", function(e) {
      e.preventDefault();
    }).bind("drop", opts.dropHandler);
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
