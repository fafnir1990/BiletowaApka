from django.core.files.storage import FileSystemStorage
from django.db import models
from os import path

from Dictionaries.models import Printeries
from Dictionaries.models import Towns
from Dictionaries.models import Organisators
from Administration.settings import MEDIA_ROOT


fs = FileSystemStorage(location=path.join(MEDIA_ROOT))


class Newsletterlogs(models.Model):
    log_id = models.AutoField(db_column='Log_ID', primary_key=True) 
    log_date = models.DateTimeField(db_column='Log_Date') 
    log_success = models.SmallIntegerField(db_column='Log_Success') 

    class Meta:
        managed = False
        db_table = 'NewsletterLogs'
        verbose_name_plural = db_table


class Resolutions(models.Model):
    res_id = models.AutoField(db_column='Res_ID', primary_key=True) 
    res_code = models.CharField(db_column='Res_Code', max_length=50) 
    res_twnid = models.ForeignKey('Dictionaries.Towns', models.DO_NOTHING, db_column='Res_TwnID') 
    res_resolution = models.BinaryField(db_column='Res_Resolution') 
    res_description = models.CharField(db_column='Res_Description', max_length=500, blank=True, null=True) 
    res_datefrom = models.DateField(db_column='Res_DateFrom') 
    res_dateto = models.DateField(db_column='Res_DateTo', blank=True, null=True) 
    res_insertdate = models.DateTimeField(db_column='Res_InsertDate') 
    res_updatedate = models.DateTimeField(db_column='Res_UpdateDate') 

    class Meta:
        managed = False
        db_table = 'Resolutions'
        unique_together = (('res_code', 'res_twnid'),)
        verbose_name_plural = db_table


class Specimens(models.Model):
    spe_id = models.AutoField(db_column='Spe_ID', primary_key=True) 
    spe_value = models.DecimalField(db_column='Spe_Value', max_digits=18, decimal_places=2) 
    spe_resid = models.ForeignKey(Resolutions, models.DO_NOTHING, db_column='Spe_ResID', blank=True, null=True) 
    spe_obverse = models.CharField(db_column='Spe_Obverse', max_length=500) 
    spe_reverse = models.CharField(db_column='Spe_Reverse', max_length=500) 
    spe_orgid = models.ForeignKey(Organisators, models.DO_NOTHING, db_column='Spe_OrgID', blank=True, null=True) 
    spe_series = models.CharField(db_column='Spe_Series', max_length=10, blank=True, null=True) 
    spe_insertdate = models.DateTimeField(db_column='Spe_InsertDate') 
    spe_updatedate = models.DateTimeField(db_column='Spe_UpdateDate') 

    class Meta:
        managed = False
        db_table = 'Specimens'
        verbose_name_plural = db_table


class Statuses(models.Model):
    sta_id = models.AutoField(db_column='Sta_ID', primary_key=True) 
    sta_name = models.CharField(db_column='Sta_Name', unique=True, max_length=20) 
    sta_description = models.CharField(db_column='Sta_Description', max_length=300, blank=True, null=True) 

    class Meta:
        managed = False
        db_table = 'Statuses'
        verbose_name_plural = db_table


class Suggestedresolutions(models.Model):
    sre_id = models.AutoField(db_column='Sre_ID', primary_key=True) 
    sre_resolution = models.CharField(db_column='Sre_Resolution', max_length=500) 
    sre_description = models.CharField(db_column='Sre_Description', max_length=500, blank=True, null=True) 
    sre_datefrom = models.DateField(db_column='Sre_DateFrom') 
    sre_dateto = models.DateField(db_column='Sre_DateTo', blank=True, null=True) 
    sre_insertdate = models.DateTimeField(db_column='Sre_InsertDate') 
    sre_updatedate = models.DateTimeField(db_column='Sre_UpdateDate') 
    sre_ownerid = models.ForeignKey('AuthUser', models.DO_NOTHING, db_column='Sre_OwnerID') 
    sre_importedcode = models.CharField(db_column='Sre_ImportedCode', max_length=50) 
    sre_importedtown = models.CharField(db_column='Sre_ImportedTown', max_length=100) 
    sre_importedpowiat = models.CharField(db_column='Sre_ImportedPowiat', max_length=100) 
    sre_importedvoivodership = models.CharField(db_column='Sre_ImportedVoivodership', max_length=100) 

    class Meta:
        managed = False
        db_table = 'SuggestedResolutions'
        verbose_name_plural = db_table


class Suggestedspecimens(models.Model):
    ssp_id = models.AutoField(db_column='Ssp_ID', primary_key=True) 
    ssp_ticid = models.ForeignKey('Tickets', models.DO_NOTHING, db_column='Ssp_TicID') 
    ssp_orgid = models.ForeignKey(Organisators, models.DO_NOTHING, db_column='Ssp_OrgID') 
    ssp_prtid = models.ForeignKey(Printeries, models.DO_NOTHING, db_column='SSp_PrtID', blank=True, null=True) 
    ssp_resid = models.ForeignKey(Resolutions, models.DO_NOTHING, db_column='Ssp_ResID', blank=True, null=True) 

    class Meta:
        managed = False
        db_table = 'SuggestedSpecimens'
        verbose_name_plural = db_table


class Tickets(models.Model):
    tic_id = models.AutoField(db_column='Tic_ID', primary_key=True) 
    tic_value = models.DecimalField(db_column='Tic_Value', max_digits=18, decimal_places=2) 
    tic_ownerid = models.ForeignKey('AuthUser', models.DO_NOTHING, db_column='Tic_OwnerID', blank=True, null=True) 
    tic_obverse = models.ImageField(db_column='Tic_Obverse', max_length=500, upload_to='Bilety/%Y%m/')
    tic_reverse = models.ImageField(db_column='Tic_Reverse', max_length=500, blank=True, null=True, upload_to='Bilety/%Y%m/')
    tic_isprivate = models.SmallIntegerField(db_column='Tic_IsPrivate') 
    tic_speid = models.ForeignKey(Specimens, models.DO_NOTHING, db_column='Tic_SpeID', blank=True, null=True) 
    tic_amount = models.IntegerField(db_column='Tic_Amount') 
    tic_series = models.CharField(db_column='Tic_Series', max_length=10, blank=True, null=True) 
    tic_importedtown = models.CharField(db_column='Tic_ImportedTown', max_length=100) 
    tic_importedpowiat = models.CharField(db_column='Tic_ImportedPowiat', max_length=100) 
    tic_importedvoivodership = models.CharField(db_column='Tic_ImportedVoivodership', max_length=100) 
    tic_importedresolutioncode = models.CharField(db_column='Tic_ImportedResolutionCode', max_length=50,
                                                  blank=True, null=True)
    tic_importedorganisatorname = models.CharField(db_column='Tic_ImportedOrganisatorName', max_length=300) 
    tic_description = models.CharField(db_column='Tic_Description', max_length=300, blank=True, null=True) 
    tic_insertdate = models.DateTimeField(db_column='Tic_InsertDate') 
    tic_updatedate = models.DateTimeField(db_column='Tic_UpdateDate') 
    tic_importedprintery = models.CharField(db_column='Tic_ImportedPrintery', max_length=300, blank=True, null=True) 

    class Meta:
        managed = False
        db_table = 'Tickets'
        verbose_name_plural = db_table


class Townsusers(models.Model):
    ciu_usrid = models.ForeignKey('AuthUser', models.DO_NOTHING, db_column='Ciu_UsrID') 
    ciu_twnid = models.ForeignKey(Towns, models.DO_NOTHING, db_column='Ciu_TwnID') 
    ciu_id = models.AutoField(db_column='Ciu_ID', primary_key=True) 

    class Meta:
        managed = False
        db_table = 'TownsUsers'
        unique_together = (('ciu_usrid', 'ciu_twnid'),)
        verbose_name_plural = db_table


class Users(models.Model):
    usr_id = models.AutoField(db_column='Usr_ID', primary_key=True) 
    usr_name = models.CharField(db_column='Usr_Name', unique=True, max_length=50) 
    usr_surname = models.CharField(db_column='Usr_Surname', max_length=50) 
    usr_firstname = models.CharField(db_column='Usr_FirstName', max_length=50) 
    usr_email = models.CharField(db_column='Usr_Email', unique=True, max_length=100) 
    usr_isadmin = models.SmallIntegerField(db_column='Usr_IsAdmin') 
    usr_password = models.CharField(db_column='Usr_Password', max_length=100) 
    usr_islocked = models.SmallIntegerField(db_column='Usr_IsLocked') 
    usr_isactivated = models.SmallIntegerField(db_column='Usr_IsActivated') 
    usr_insertdate = models.DateTimeField(db_column='Usr_InsertDate') 
    usr_updatedate = models.DateTimeField(db_column='Usr_UpdateDate') 
    usr_lastconnectiondate = models.DateTimeField(db_column='Usr_LastConnectionDate', blank=True, null=True) 

    class Meta:
        managed = False
        db_table = 'Users'
        verbose_name_plural = db_table


class Usersticketsshare(models.Model):
    uti_id = models.AutoField(db_column='Uti_ID', primary_key=True) 
    uti_usrid = models.ForeignKey('AuthUser', models.DO_NOTHING, db_column='Uti_UsrID') 
    uti_ticid = models.ForeignKey(Tickets, models.DO_NOTHING, db_column='Uti_TicID') 

    class Meta:
        managed = False
        db_table = 'UsersTicketsShare'
        unique_together = (('uti_usrid', 'uti_ticid'),)
        verbose_name_plural = db_table


class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=80)

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.BooleanField()
    username = models.CharField(unique=True, max_length=30)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    email = models.CharField(max_length=254)
    is_staff = models.BooleanField()
    is_active = models.BooleanField()
    date_joined = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'auth_user'

    def __str__(self):
        return self.username


class AuthUserGroups(models.Model):
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(blank=True, null=True)
    object_repr = models.CharField(max_length=200)
    action_flag = models.SmallIntegerField()
    change_message = models.TextField()
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField()
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'


class Sysdiagrams(models.Model):
    name = models.CharField(max_length=128)
    principal_id = models.IntegerField()
    diagram_id = models.AutoField(primary_key=True)
    version = models.IntegerField(blank=True, null=True)
    definition = models.BinaryField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'sysdiagrams'
        unique_together = (('principal_id', 'name'),)
