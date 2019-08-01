from django.urls import path

from . import views

from django.views.generic import TemplateView
from django.conf.urls.static import static
from django.conf import settings

urlpatterns = [

    path('bilety/', views.TicketsListView.as_view(), name='tickets'),
    path('<int:pk>/', views.TicketsDetailView.as_view(), name='detail'),
    path('<int:pk>/update', views.TicketsUpdateView.as_view(), name='update'),
    path('create/', views.TicketsCreateView.as_view(), name='create'),
    path('about/', TemplateView.as_view(template_name="samples/about.html"), name='about'),
    path('about-class/', views.AboutView.as_view(), name='about_class'),
    path('', views.TicketsListView.as_view(), name='bilety'),

] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
