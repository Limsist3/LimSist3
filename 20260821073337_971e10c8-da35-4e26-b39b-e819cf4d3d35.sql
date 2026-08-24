REVOKE ALL ON FUNCTION public.sms_creditar(uuid, integer, integer) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.sms_definir_saldo(uuid, integer, integer) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.sms_consumir(uuid, integer) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.sms_aprovar_recarga(uuid) FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.sms_rejeitar_recarga(uuid, text) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION public.sms_creditar(uuid, integer, integer) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.sms_definir_saldo(uuid, integer, integer) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.sms_consumir(uuid, integer) TO service_role;
GRANT EXECUTE ON FUNCTION public.sms_aprovar_recarga(uuid) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.sms_rejeitar_recarga(uuid, text) TO authenticated, service_role;