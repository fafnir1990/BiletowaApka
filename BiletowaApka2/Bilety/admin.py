from django.contrib import admin

from django.contrib import admin
from .models import Organisators
from .models import Resolutions
from .models import Specimens
from .models import Suggestedresolutions
from .models import Suggestedspecimens
from .models import Tickets
from .models import Towns
from .models import Users
from .models import Usersticketsshare
from .models import Townsusers


class TicketsAdmin(admin.ModelAdmin):
    list_display = ('tic_id', 'tic_obverse', 'tic_reverse')


admin.site.register(Townsusers)
admin.site.register(Usersticketsshare)
admin.site.register(Resolutions)
admin.site.register(Specimens)
admin.site.register(Suggestedresolutions)
admin.site.register(Suggestedspecimens)
admin.site.register(Tickets, TicketsAdmin)
admin.site.register(Towns)
admin.site.register(Users)

