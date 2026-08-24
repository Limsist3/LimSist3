REVOKE EXECUTE ON FUNCTION public.aplicar_capitalizacao_automatica(uuid) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.aplicar_capitalizacao_automatica(uuid) FROM anon;
GRANT EXECUTE ON FUNCTION public.aplicar_capitalizacao_automatica(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.aplicar_capitalizacao_automatica(uuid) TO service_role;