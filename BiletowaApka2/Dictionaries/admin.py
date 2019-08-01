from django.contrib import admin

from .models import Voivoderships
from .models import Printeries
from .models import Powiats
from .models import Organisators
# Register your models here.

class VoivodershipsAdmin(admin.ModelAdmin):
    list_display = ('voi_id', 'voi_name')
    list_filter = ('voi_name',)
    search_fields = ('voi_name',)
    ordering = ('voi_name',)


class PowiatsAdmin(admin.ModelAdmin):
    list_display = ('pow_id', 'pow_name', 'pow_voiid')
    raw_id_fields = ('pow_voiid',)
    list_filter = ('pow_voiid',)
    search_fields = ('pow_name',)
    ordering = ('pow_name',)


class OrganisatorsAdmin(admin.ModelAdmin):
    list_display = ('org_id', 'org_name', 'org_abbreviation', 'org_twnid')


class PrinteriesAdmin(admin.ModelAdmin):
    list_display = ('prt_id', 'prt_name', 'prt_abbreviation')


admin.site.register(Voivoderships, VoivodershipsAdmin)
admin.site.register(Powiats, PowiatsAdmin)
admin.site.register(Organisators, OrganisatorsAdmin)
admin.site.register(Printeries, PrinteriesAdmin)
