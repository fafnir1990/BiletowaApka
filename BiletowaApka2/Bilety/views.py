from django.shortcuts import render
from django.http import HttpResponse
from django.template import loader
from django.shortcuts import render
from django.shortcuts import render, get_object_or_404, redirect
from django.views import View, generic
from django.urls import reverse_lazy
import datetime



from .models import Tickets
from .forms import TicketForm


class TicketsCreateView(generic.CreateView):
    # def __init__(self, request):
    #     self.user_id = request.user.id

    # model = Tickets
    form_class = TicketForm
    template_name = 'Bilety/tickets_form.html'
    success_url = reverse_lazy('bilety')

    # def get_form(self, form_class=None):
    #     return super(form_class, self).get_form(form_class)

    # def __init__(self, request):
    #     self.request = request
    #
    # def form_valid(self, form):
    #     form.save(commit=False)
    #     form.instance.owner_id = self.request.user
    #     form.instance.tic_insertdate = datetime.date.today()
    #     form.instance.tic_updatedate = datetime.date.today()
    #     return super(TicketsCreateView, self).form_valid(form)
    #     # form.save()
    #     # return super(TicketsCreateView, self).form_valid(form)

    # def upload(request):
    #     if request.method == 'POST':
    #         form = TicketForm(request.POST, request.FILES)
    #         if form.is_valid():
    #             form.save()
    #             return redirect('home')
    #     else:
    #         form = TicketForm()
    #     return render(request, 'core/model_form_upload.html', {
    #         'form': form
    #     })

    # def form_valid(self, form):
    #     ticket = Tickets.objects.create()
    #     tickettic_ownerid = self.request.user
    #     super(TicketsCreateView, self).form_valid(form)
    #     return redirect('/Bilety/%d/' % (list.id,))


class TicketsUpdateView(generic.UpdateView):
    model = Tickets
    fields = '__all__'

    def get_success_url(self):
        return reverse_lazy('voivoderships_detail', args=[self.kwargs['pk']])


class TicketsListView(generic.ListView):
    model = Tickets
    context_object_name = 'tickets_list'   # your own name for the list as a template variable
    queryset = Tickets.objects.all()
    template_name = 'Tickets/tickets_list.html'  # Specify your own template name/location


class TicketsDetailView(generic.DetailView):
    model = Tickets


class AboutView(generic.TemplateView):
    template_name = 'Tickets/about.html'

    def get_context_data(self):
        context = {'dynamic_val': 'this info changes'}
        return context

