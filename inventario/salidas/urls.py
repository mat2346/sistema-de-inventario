from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import SalidaViewSet

router = DefaultRouter()
router.register(r'salidas', SalidaViewSet)

urlpatterns = [
    path('api/', include(router.urls)),
]
