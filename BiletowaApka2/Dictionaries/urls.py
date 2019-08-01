from django.urls import path

from . import views

from django.views.generic import TemplateView

urlpatterns = [
    path('', TemplateView.as_view(template_name="base.html"), name='dictionaries'),
    path('voivoderships/', views.VoivodershipsList.as_view(), name='voivoderships'),
    path('voivoderships/<int:pk>/update/', views.VoivodershipsUpdateView.as_view(), name='voivoderships_update'),
    path('voivoderships/create/', views.VoivodershipsCreateView.as_view(), name='voivoderships_create'),
    path('voivoderships/<int:pk>/', views.VoivodershipsDetailView.as_view(), name='voivoderships_detail'),

    path('powiats/', views.PowiatsList.as_view(), name='powiats'),
    path('powiats/<int:pk>/', views.PowiatsDetailView.as_view(), name='powiats_detail'),

    path('organizatorzy/', views.OrganistorsList.as_view(), name='organisators'),
    path('organizatorzy/<int:pk>/', views.OrganisatorsDetailView.as_view(), name='organisators_detail'),

    path('drukarnie/', views.PrinteriesList.as_view(), name='printeries'),
    path('drukarnie/<int:pk>/', views.PrinteriesDetailView.as_view(), name='printeries_detail'),

    path('miejscowosci/', views.TownsList.as_view(), name='towns'),
    path('miejscowosci/<int:pk>/', views.TownsDetailView.as_view(), name='towns_detail'),

]
