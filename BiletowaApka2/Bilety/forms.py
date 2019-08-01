from django import forms

from crispy_forms.helper import FormHelper
from crispy_forms.layout import Layout, Fieldset, ButtonHolder, Submit

from Bilety.models import Tickets


class TicketForm(forms.ModelForm):

    # def __init__(self, request, *args, **kwargs):
    #     self.user = request.user
    #     super(TicketForm, self).__init__(*args, **kwargs)

    # def save(self, commit=True):
    #     instance = super(TicketForm, self).save(commit=False)
    #     instance.tic_ownerid = self.user.id
    #
    #     if commit:
    #         instance.save()
    #     return instance

    class Meta:
        model = Tickets
        # fields = '__all__'
        fields = ('tic_value'
                ,'tic_ownerid', 'tic_obverse'
                ,'tic_reverse', 'tic_isprivate'
                , 'tic_speid', 'tic_amount'
                , 'tic_series', 'tic_importedtown'
                , 'tic_importedpowiat', 'tic_importedvoivodership'
                , 'tic_importedresolutioncode', 'tic_importedorganisatorname'
                , 'tic_description', 'tic_importedprintery'
                , 'tic_insertdate', 'tic_updatedate', 'tic_ownerid')
        # exclude = ('tic_ownerid',)



