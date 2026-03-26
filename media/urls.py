from django.urls import re_path

from . import views

urlpatterns = [
  re_path(r'^photo/search/$',views.photo_search,name='photo_search'),
  re_path(r'^photo/tag/$',views.tag_photo,name='tag_photo'),
  re_path(r'^photo/insert/$',views.insert_photo,name='insert_photo'),
  re_path(r'^photo/add/$',views.add_photo,name='add_photo'),
  re_path(r'^photo/bulk_tag/$',views.bulk_tag_index,name='bulk_tag_index'),
  re_path(r'^photo/bulk_tag/(\d+)/$',views.bulk_tag_detail,name='bulk_tag_detail'),
  re_path(r'^photo/bulk_upload/$',views.bulk_photo_upload,name='bulk_photo_upload'),
  re_path(r'^photo/untag/$',views.untag_photo,name='untag_photo'),
  re_path(r'^photo/delete/(\d+)/$',views.delete_photo,name='delete_photo'),
  re_path(r'^photo/edit/(\d+)/$',views.edit_photo,name='edit_photo'),
  re_path(r'^photo/order/$',views.order,name='photo_order'),
  re_path(r'^private/$',views.post_file,name="post_private_file"),
  re_path(r'^private/(.*)',views.private_file,name='private_file'),
]
