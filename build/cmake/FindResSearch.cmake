include(CheckSymbolExists)

set (MONGOC_HAVE_DNSAPI 0)
set (MONGOC_HAVE_RES_NSEARCH 0)
set (MONGOC_HAVE_RES_NDESTROY 0)
set (MONGOC_HAVE_RES_NCLOSE 0)
set (MONGOC_HAVE_RES_SEARCH 0)

if (ENABLE_SRV STREQUAL ON OR ENABLE_SRV STREQUAL AUTO)
   if (WIN32)
      set (RESOLV_LIBS Dnsapi)
      set (MONGOC_HAVE_DNSAPI 1)
   else ()
      set (MONGOC_HAVE_DNSAPI 0)
      # Thread-safe DNS query function for _mongoc_client_get_srv.
      # Could be a macro, not a function, so use check_symbol_exists.
      check_symbol_exists (res_nsearch resolv.h MONGOC_HAVE_RES_NSEARCH)
      if (MONGOC_HAVE_RES_NSEARCH)
         set (RESOLV_LIBS resolv)

         # We have res_nsearch. Call res_ndestroy (BSD/Mac) or res_nclose (Linux)?
         check_symbol_exists (res_ndestroy resolv.h MONGOC_HAVE_RES_NDESTROY)
         if (NOT MONGOC_HAVE_RES_NDESTROY)
            check_symbol_exists (res_nclose resolv.h MONGOC_HAVE_RES_NCLOSE)
         endif ()
      else ()
         # Thread-unsafe function.
         check_symbol_exists (res_search resolv.h MONGOC_HAVE_RES_SEARCH)
         if (MONGOC_HAVE_RES_SEARCH)
            set (RESOLV_LIBS resolv)
         endif()
      endif ()
   endif ()
endif ()

if (ENABLE_SRV STREQUAL ON AND NOT RESOLV_LIBS)
   message (
      FATAL_ERROR
      "Cannot find libresolv or dnsapi. Try setting ENABLE_SRV=OFF")
endif ()
