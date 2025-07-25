from django.contrib import admin
from django import forms
from .models import Empleado

class EmpleadoAdminForm(forms.ModelForm):
    password = forms.CharField(
        widget=forms.PasswordInput(),
        help_text="Ingresa la contraseña sin encriptar"
    )
    
    class Meta:
        model = Empleado
        fields = '__all__'
    
    def save(self, commit=True):
        empleado = super().save(commit=False)
        # Solo encriptar si la contraseña cambió
        if self.cleaned_data['password']:
            empleado.set_password(self.cleaned_data['password'])
        if commit:
            empleado.save()
        return empleado

@admin.register(Empleado)
class EmpleadoAdmin(admin.ModelAdmin):
    form = EmpleadoAdminForm
    list_display = ('get_full_name', 'cargo', 'correo', 'sucursal', 'is_active')
    list_filter = ('cargo', 'sucursal', 'is_active')
    search_fields = ('nombre', 'apellido', 'correo')
    
    def get_full_name(self, obj):
        return obj.get_full_name()
    get_full_name.short_description = 'Nombre Completo'
