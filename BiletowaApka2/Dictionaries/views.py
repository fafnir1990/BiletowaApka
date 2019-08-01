from django.shortcuts import render
from django.shortcuts import render, get_object_or_404, redirect
from django.views import View, generic
from django.urls import reverse_lazy

from .models import Towns
from .models import Voivoderships
from .models import Powiats
from .models import Printeries
from .models import Organisators

def index_towns(request):
    towns_list = Towns.objects.all()
    return render(request, 'Dictionaries/towns_index.html', {"towns":towns_list})


def index_voivoderships(request):
    voi_list = Voivoderships.objects.all()
    return render(request, 'Dictionaries/voivoderships_list.html', {"voivoderships":voi_list})


class VoivodershipsList(generic.ListView):
    model = Voivoderships
    fields = '__all__'
    context_object_name = 'voivoderships_list'
    queryset = Voivoderships.objects.all()
    paginate_by = 20
    template_name = 'Dictionaries/voivoderships_list.html'

class VoivodershipsCreateView(generic.CreateView):
    model = Voivoderships
    fields = '__all__'

class VoivodershipsDetailView(generic.DetailView):
    model = Voivoderships

class VoivodershipsUpdateView(generic.UpdateView):
    model = Voivoderships
    fields = '__all__'

    def get_success_url(self):
        return reverse_lazy('voivoderships_detail'
                            , args=[self.kwargs['pk']])


class PowiatsList(generic.ListView):
    model = Powiats
    fields = '__all__'
    context_object_name = 'powiats_list'   # your own name for the list as a template variable
    queryset = Powiats.objects.all()
    template_name = 'Dictionaries/powiats_list.html'  # Specify your own template name/location
    raw_id_fields = ('pow_voiid',)


class PrinteriesList(generic.ListView):
    model = Printeries
    fields = '__all__'
    context_object_name = 'printeries_list'   # your own name for the list as a template variable
    queryset = Printeries.objects.all()
    template_name = 'Dictionaries/printeries_list.html'  # Specify your own template name/location


class OrganistorsList(generic.ListView):
    model = Organisators
    fields = '__all__'
    context_object_name = 'organistors_list'   # your own name for the list as a template variable
    queryset = Organisators.objects.all()
    template_name = 'Dictionaries/organistors_list.html'  # Specify your own template name/location


class OrganisatorsDetailView(generic.DetailView):
    model = Organisators


class PowiatsDetailView(generic.DetailView):
    model = Powiats


class PrinteriesDetailView(generic.DetailView):
    model = Printeries

class TownsList(generic.ListView):
    model = Towns
    fields = '__all__'
    context_object_name = 'towns_list'   # your own name for the list as a template variable
    queryset = Towns.objects.all()
    template_name = 'Dictionaries/towns_list.html'  # Specify your own template name/location


class TownsDetailView(generic.DetailView):
    model = Towns

