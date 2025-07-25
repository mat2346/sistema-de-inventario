from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import EntradaViewSet

router = DefaultRouter()
router.register(r'entradas', EntradaViewSet)

urlpatterns = [
    path('api/', include(router.urls)),
]
