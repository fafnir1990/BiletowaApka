from django.db import models


class Powiats(models.Model):
    pow_id = models.AutoField(db_column='Pow_ID', primary_key=True, verbose_name='ID')  # Field name made lowercase.
    pow_name = models.CharField(db_column='Pow_Name', max_length=100, verbose_name='Nazwa')
    pow_voiid = models.ForeignKey('Voivoderships', models.DO_NOTHING, db_column='Pow_VoiID', verbose_name='Wojewodztwo')

    class Meta:
        managed = False
        db_table = 'Powiats'
        unique_together = (('pow_name', 'pow_voiid'),)
        verbose_name_plural = db_table

    def __str__(self):
        return self.pow_name


class Printeries(models.Model):
    prt_id = models.AutoField(db_column='Prt_ID', primary_key=True, verbose_name='ID')  # Field name made lowercase.
    prt_name = models.CharField(db_column='Prt_Name', unique=True, max_length=300, verbose_name='Nazwa')  # Field name made lowercase.
    prt_abbreviation = models.CharField(db_column='Prt_Abbreviation', max_length=300, blank=True, null=True,
                                        verbose_name='Akronim')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Printeries'
        verbose_name_plural = db_table

    def __str__(self):
        return self.prt_name


class Voivoderships(models.Model):
    voi_id = models.AutoField(db_column='Voi_ID'
                              , primary_key=True
                              , verbose_name='ID')
    voi_name = models.CharField(db_column='Voi_Name'
                                , unique=True
                                , max_length=100
                                , verbose_name='Nazwa')

    class Meta:
        managed = False
        db_table = 'Voivoderships'
        verbose_name_plural = db_table

    def __str__(self):
        return self.voi_name


class Organisators(models.Model):
    org_id = models.AutoField(db_column='Org_ID', primary_key=True, verbose_name='ID')  # Field name made lowercase.
    org_name = models.CharField(db_column='Org_Name', max_length=300, verbose_name='Nazwa')  # Field name made lowercase.
    org_abbreviation = models.CharField(db_column='Org_Abbreviation', max_length=50, blank=True, null=True
                                        ,verbose_name='Akronim')  # Field name made lowercase.
    org_twnid = models.ForeignKey('Towns', models.DO_NOTHING, db_column='Org_TwnID', verbose_name='Miejscowosc')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Organisators'
        unique_together = (('org_name', 'org_twnid'),)
        verbose_name_plural = db_table

    def __str__(self):
        return self.org_name


class Towns(models.Model):
    twn_id = models.AutoField(db_column='Twn_ID', primary_key=True, verbose_name='ID')  # Field name made lowercase.
    twn_name = models.CharField(db_column='Twn_Name', max_length=100, verbose_name='Nazwa')  # Field name made lowercase.
    twn_powid = models.ForeignKey(Powiats, models.DO_NOTHING, db_column='Twn_PowID', verbose_name='Powiat')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Towns'
        unique_together = (('twn_name', 'twn_powid'),)
        verbose_name_plural = db_table
        ordering = ['twn_name']

    def __str__(self):
        return self.twn_name

