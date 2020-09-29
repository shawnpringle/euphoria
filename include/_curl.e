-- This file was generated by curlimport.e.
include std/dll.e

constant dll = open_dll({
  "libcurl.so",
  "libcurl.dll"
})



public constant CURLOPTTYPE_OBJECTPOINT = 10000
public constant CURLOPTTYPE_STRINGPOINT = CURLOPTTYPE_OBJECTPOINT
public constant CURLOPT_URL = CURLOPTTYPE_STRINGPOINT + 2
public constant CURLE_ALREADY_COMPLETE = 99999
public constant CURLGSSAPI_DELEGATION_NONE = 0
public constant CURLINFO_DOUBLE = 0
public constant CURLINFO_LONG = 0
public constant CURLINFO_OFF_T = 0
public constant CURLINFO_SLIST = 0
public constant CURLINFO_STRING = 0
public constant CURLOPTTYPE_FUNCTIONPOINT = 20000
public constant CURLOPTTYPE_OFF_T = 30000
public constant CURLOPT_ABSTRACT_UNIX_SOCKET = CURLOPTTYPE_STRINGPOINT + 264
public constant CURLOPT_ACCEPT_ENCODING = CURLOPTTYPE_STRINGPOINT + 102
public constant CURLOPT_ALTSVC = CURLOPTTYPE_STRINGPOINT + 287
public constant CURLOPTTYPE_LONG = 0
public constant CURLOPT_APPEND = CURLOPTTYPE_LONG + 50
public constant CURLOPT_CAINFO = CURLOPTTYPE_STRINGPOINT + 65
public constant CURLOPT_CERTINFO = CURLOPTTYPE_LONG + 172
public constant CURLOPT_CHUNK_DATA = CURLOPTTYPE_OBJECTPOINT + 201
public constant CURLOPT_OBSOLETE72 = CURLOPTTYPE_LONG + 72
public constant CURLOPT_CLOSEPOLICY = CURLOPT_OBSOLETE72
public constant CURLOPT_CLOSESOCKETFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 208
public constant CURLOPT_CONNECTTIMEOUT_MS = CURLOPTTYPE_LONG + 156
public constant CURLOPTTYPE_SLISTPOINT = CURLOPTTYPE_OBJECTPOINT
public constant CURLOPT_CONNECT_TO = CURLOPTTYPE_SLISTPOINT + 243
public constant CURLOPT_CONV_TO_NETWORK_FUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 143
public constant CURLOPT_COOKIEFILE = CURLOPTTYPE_STRINGPOINT + 31
public constant CURLOPT_COOKIELIST = CURLOPTTYPE_STRINGPOINT + 135
public constant CURLOPT_COPYPOSTFIELDS = CURLOPTTYPE_OBJECTPOINT + 165
public constant CURLOPT_CRLFILE = CURLOPTTYPE_STRINGPOINT + 169
public constant CURLOPT_CUSTOMREQUEST = CURLOPTTYPE_STRINGPOINT + 36
public constant CURLOPT_DEBUGFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 94
public constant CURLOPT_DIRLISTONLY = CURLOPTTYPE_LONG + 48
public constant CURLOPT_DNS_CACHE_TIMEOUT = CURLOPTTYPE_LONG + 92
public constant CURLOPT_DNS_LOCAL_IP4 = CURLOPTTYPE_STRINGPOINT + 222
public constant CURLOPT_DNS_SERVERS = CURLOPTTYPE_STRINGPOINT + 211
public constant CURLOPT_DNS_USE_GLOBAL_CACHE = CURLOPTTYPE_LONG + 91
public constant CURLOPT_EGDSOCKET = CURLOPTTYPE_STRINGPOINT + 77
public constant CURLOPT_ERRORBUFFER = CURLOPTTYPE_OBJECTPOINT + 10
public constant CURLOPT_FAILONERROR = CURLOPTTYPE_LONG + 45
public constant CURLOPT_FILETIME = CURLOPTTYPE_LONG + 69
public constant CURLOPT_FNMATCH_FUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 200
public constant CURLOPT_FORBID_REUSE = CURLOPTTYPE_LONG + 75
public constant CURLOPT_FTPAPPEND = CURLOPT_APPEND
public constant CURLOPT_FTPPORT = CURLOPTTYPE_STRINGPOINT + 17
public constant CURLOPT_FTP_ACCOUNT = CURLOPTTYPE_STRINGPOINT + 134
public constant CURLOPT_FTP_CREATE_MISSING_DIRS = CURLOPTTYPE_LONG + 110
public constant CURLOPT_FTP_RESPONSE_TIMEOUT = CURLOPTTYPE_LONG + 112
public constant CURLOPT_USE_SSL = CURLOPTTYPE_LONG + 119
public constant CURLOPT_FTP_SSL = CURLOPT_USE_SSL
public constant CURLOPT_FTP_USE_EPRT = CURLOPTTYPE_LONG + 106
public constant CURLOPT_FTP_USE_PRET = CURLOPTTYPE_LONG + 188
public constant CURLOPT_HAPPY_EYEBALLS_TIMEOUT_MS = CURLOPTTYPE_LONG + 271
public constant CURLOPT_HEADER = CURLOPTTYPE_LONG + 42
public constant CURLOPT_HEADERFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 79
public constant CURLOPT_HTTP09_ALLOWED = CURLOPTTYPE_LONG + 285
public constant CURLOPT_HTTPAUTH = CURLOPTTYPE_LONG + 107
public constant CURLOPT_HTTPHEADER = CURLOPTTYPE_SLISTPOINT + 23
public constant CURLOPT_HTTPPROXYTUNNEL = CURLOPTTYPE_LONG + 61
public constant CURLOPT_HTTP_TRANSFER_DECODING = CURLOPTTYPE_LONG + 157
public constant CURLOPT_IGNORE_CONTENT_LENGTH = CURLOPTTYPE_LONG + 136
public constant CURLOPT_INFILESIZE = CURLOPTTYPE_LONG + 14
public constant CURLOPT_INTERFACE = CURLOPTTYPE_STRINGPOINT + 62
public constant CURLOPT_INTERLEAVEFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 196
public constant CURLOPT_IOCTLFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 130
public constant CURLOPT_ISSUERCERT = CURLOPTTYPE_STRINGPOINT + 170
public constant CURLOPT_KEYPASSWD = CURLOPTTYPE_STRINGPOINT + 26
public constant CURLOPT_LOCALPORT = CURLOPTTYPE_LONG + 139
public constant CURLOPT_LOGIN_OPTIONS = CURLOPTTYPE_STRINGPOINT + 224
public constant CURLOPT_LOW_SPEED_TIME = CURLOPTTYPE_LONG + 20
public constant CURLOPT_MAIL_FROM = CURLOPTTYPE_STRINGPOINT + 186
public constant CURLOPT_MAIL_RCPT_ALLLOWFAILS = CURLOPTTYPE_LONG + 290
public constant CURLOPT_MAXCONNECTS = CURLOPTTYPE_LONG + 71
public constant CURLOPT_MAXFILESIZE_LARGE = CURLOPTTYPE_OFF_T + 117
public constant CURLOPT_MAX_RECV_SPEED_LARGE = CURLOPTTYPE_OFF_T + 146
public constant CURLOPT_MIMEPOST = CURLOPTTYPE_OBJECTPOINT + 269
public constant CURLOPT_NETRC_FILE = CURLOPTTYPE_STRINGPOINT + 118
public constant CURLOPT_NEW_FILE_PERMS = CURLOPTTYPE_LONG + 159
public constant CURLOPT_NOPROGRESS = CURLOPTTYPE_LONG + 43
public constant CURLOPT_NOSIGNAL = CURLOPTTYPE_LONG + 99
public constant CURLOPT_OPENSOCKETDATA = CURLOPTTYPE_OBJECTPOINT + 164
public constant CURLOPT_PASSWORD = CURLOPTTYPE_STRINGPOINT + 174
public constant CURLOPT_PINNEDPUBLICKEY = CURLOPTTYPE_STRINGPOINT + 230
public constant CURLOPT_PORT = CURLOPTTYPE_LONG + 3
public constant CURLOPT_POSTFIELDS = CURLOPTTYPE_OBJECTPOINT + 15
public constant CURLOPT_POSTFIELDSIZE_LARGE = CURLOPTTYPE_OFF_T + 120
public constant CURLOPT_POSTREDIR = CURLOPTTYPE_LONG + 161
public constant CURLOPT_PRE_PROXY = CURLOPTTYPE_STRINGPOINT + 262
public constant CURLOPT_PROGRESSDATA = CURLOPTTYPE_OBJECTPOINT + 57
public constant CURLOPT_PROTOCOLS = CURLOPTTYPE_LONG + 181
public constant CURLOPT_PROXYAUTH = CURLOPTTYPE_LONG + 111
public constant CURLOPT_PROXYPASSWORD = CURLOPTTYPE_STRINGPOINT + 176
public constant CURLOPT_PROXYTYPE = CURLOPTTYPE_LONG + 101
public constant CURLOPT_PROXYUSERPWD = CURLOPTTYPE_STRINGPOINT + 6
public constant CURLOPT_PROXY_CAPATH = CURLOPTTYPE_STRINGPOINT + 247
public constant CURLOPT_PROXY_KEYPASSWD = CURLOPTTYPE_STRINGPOINT + 258
public constant CURLOPT_PROXY_SERVICE_NAME = CURLOPTTYPE_STRINGPOINT + 235
public constant CURLOPT_PROXY_SSLCERTTYPE = CURLOPTTYPE_STRINGPOINT + 255
public constant CURLOPT_PROXY_SSLKEYTYPE = CURLOPTTYPE_STRINGPOINT + 257
public constant CURLOPT_PROXY_SSL_CIPHER_LIST = CURLOPTTYPE_STRINGPOINT + 259
public constant CURLOPT_PROXY_SSL_VERIFYHOST = CURLOPTTYPE_LONG + 249
public constant CURLOPT_PROXY_TLS13_CIPHERS = CURLOPTTYPE_STRINGPOINT + 277
public constant CURLOPT_PROXY_TLSAUTH_TYPE = CURLOPTTYPE_STRINGPOINT + 253
public constant CURLOPT_PROXY_TRANSFER_MODE = CURLOPTTYPE_LONG + 166
public constant CURLOPT_QUOTE = CURLOPTTYPE_SLISTPOINT + 28
public constant CURLOPT_RANGE = CURLOPTTYPE_STRINGPOINT + 7
public constant CURLOPT_READFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 12
public constant CURLOPT_REFERER = CURLOPTTYPE_STRINGPOINT + 16
public constant CURLOPT_RESOLVE = CURLOPTTYPE_SLISTPOINT + 203
public constant CURLOPT_RESOLVER_START_FUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 272
public constant CURLOPT_RESUME_FROM_LARGE = CURLOPTTYPE_OFF_T + 116
public constant CURLOPT_RTSP_CLIENT_CSEQ = CURLOPTTYPE_LONG + 193
public constant CURLOPT_RTSP_SERVER_CSEQ = CURLOPTTYPE_LONG + 194
public constant CURLOPT_RTSP_STREAM_URI = CURLOPTTYPE_STRINGPOINT + 191
public constant CURLOPT_SASL_AUTHZID = CURLOPTTYPE_STRINGPOINT + 289
public constant CURLOPT_SEEKDATA = CURLOPTTYPE_OBJECTPOINT + 168
public constant CURLOPT_SERVER_RESPONSE_TIMEOUT = CURLOPT_FTP_RESPONSE_TIMEOUT
public constant CURLOPT_SHARE = CURLOPTTYPE_OBJECTPOINT + 100
public constant CURLOPT_SOCKOPTFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 148
public constant CURLOPT_SOCKS5_GSSAPI_NEC = CURLOPTTYPE_LONG + 180
public constant CURLOPT_SSH_AUTH_TYPES = CURLOPTTYPE_LONG + 151
public constant CURLOPT_SSH_HOST_PUBLIC_KEY_MD5 = CURLOPTTYPE_STRINGPOINT + 162
public constant CURLOPT_SSH_KEYFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 184
public constant CURLOPT_SSH_PRIVATE_KEYFILE = CURLOPTTYPE_STRINGPOINT + 153
public constant CURLOPT_SSLCERT = CURLOPTTYPE_STRINGPOINT + 25
public constant CURLOPT_SSLCERTTYPE = CURLOPTTYPE_STRINGPOINT + 86
public constant CURLOPT_SSLENGINE_DEFAULT = CURLOPTTYPE_LONG + 90
public constant CURLOPT_SSLKEYPASSWD = CURLOPT_KEYPASSWD
public constant CURLOPT_SSLVERSION = CURLOPTTYPE_LONG + 32
public constant CURLOPT_SSL_CTX_DATA = CURLOPTTYPE_OBJECTPOINT + 109
public constant CURLOPT_SSL_ENABLE_ALPN = CURLOPTTYPE_LONG + 226
public constant CURLOPT_SSL_FALSESTART = CURLOPTTYPE_LONG + 233
public constant CURLOPT_SSL_SESSIONID_CACHE = CURLOPTTYPE_LONG + 150
public constant CURLOPT_SSL_VERIFYPEER = CURLOPTTYPE_LONG + 64
public constant CURLOPT_STDERR = CURLOPTTYPE_OBJECTPOINT + 37
public constant CURLOPT_STREAM_DEPENDS_E = CURLOPTTYPE_OBJECTPOINT + 241
public constant CURLOPT_SUPPRESS_CONNECT_HEADERS = CURLOPTTYPE_LONG + 265
public constant CURLOPT_TCP_KEEPALIVE = CURLOPTTYPE_LONG + 213
public constant CURLOPT_TCP_KEEPINTVL = CURLOPTTYPE_LONG + 215
public constant CURLOPT_TELNETOPTIONS = CURLOPTTYPE_SLISTPOINT + 70
public constant CURLOPT_TFTP_NO_OPTIONS = CURLOPTTYPE_LONG + 242
public constant CURLOPT_TIMEOUT = CURLOPTTYPE_LONG + 13
public constant CURLOPT_TIMEVALUE = CURLOPTTYPE_LONG + 34
public constant CURLOPT_TLS13_CIPHERS = CURLOPTTYPE_STRINGPOINT + 276
public constant CURLOPT_TLSAUTH_TYPE = CURLOPTTYPE_STRINGPOINT + 206
public constant CURLOPT_TRAILERDATA = CURLOPTTYPE_OBJECTPOINT + 284
public constant CURLOPT_TRANSFERTEXT = CURLOPTTYPE_LONG + 53
public constant CURLOPT_UNIX_SOCKET_PATH = CURLOPTTYPE_STRINGPOINT + 231
public constant CURLOPT_UPKEEP_INTERVAL_MS = CURLOPTTYPE_LONG + 281
public constant CURLOPT_UPLOAD_BUFFERSIZE = CURLOPTTYPE_LONG + 280
public constant CURLOPT_USERNAME = CURLOPTTYPE_STRINGPOINT + 173
public constant CURLOPT_VERBOSE = CURLOPTTYPE_LONG + 41
public constant CURLOPT_WRITEDATA = CURLOPTTYPE_OBJECTPOINT + 1
public constant CURLOPT_HEADERDATA = CURLOPTTYPE_OBJECTPOINT + 29
public constant CURLOPT_WRITEHEADER = CURLOPT_HEADERDATA
public constant CURLOPT_XFERINFOFUNCTION = CURLOPTTYPE_FUNCTIONPOINT + 219
public constant CURLPROTO_DICT = power(2,9)
public constant CURLPROTO_FTP = power(2,2)
public constant CURLPROTO_GOPHER = power(2,25)
public constant CURLPROTO_HTTPS = power(2,1)
public constant CURLPROTO_IMAPS = power(2,13)
public constant CURLPROTO_LDAPS = power(2,8)
public constant CURLPROTO_RTMP = power(2,19)
public constant CURLPROTO_RTMPS = power(2,23)
public constant CURLPROTO_RTMPTE = power(2,22)
public constant CURLPROTO_RTSP = power(2,18)
public constant CURLPROTO_SFTP = power(2,5)
public constant CURLPROTO_SMBS = power(2,27)
public constant CURLPROTO_SMTPS = power(2,17)
public constant CURLPROTO_TFTP = power(2,11)
public constant CURLSSH_AUTH_NONE = 0
public constant CURL_CHUNK_BGN_FUNC_FAIL = 1
public constant CURL_CHUNK_BGN_FUNC_SKIP = 2
public constant CURL_CHUNK_END_FUNC_OK = 0
public constant CURL_FNMATCHFUNC_FAIL = 2
public constant CURL_FNMATCHFUNC_NOMATCH = 1
public constant CURL_GLOBAL_NOTHING = 0
public constant CURL_IPRESOLVE_WHATEVER = 0
public constant CURL_MAX_WRITE_SIZE = 16384
public constant CURL_READFUNC_ABORT = 0
public constant CURL_REDIR_GET_ALL = 0
public constant CURL_SEEKFUNC_FAIL = 1
public constant CURL_SOCKOPT_ALREADY_CONNECTED = 2
public constant CURL_SOCKOPT_OK = 0
public constant CURL_TRAILERFUNC_OK = 0
public constant CURL_WRITEFUNC_PAUSE = 0
--
export constant curl_strequalx = define_c_func(dll, "+curl_strequal",{C_POINTER, C_POINTER}, C_INT)
export function curl_strequal(atom s, atom arg2)
	return c_func(curl_strequalx, {s,arg2})
end function
export constant C_SIZE_T = C_POINTER
--
export constant curl_strnequalx = define_c_func(dll, "+curl_strnequal",{C_POINTER, C_POINTER, C_SIZE_T}, C_INT)
export function curl_strnequal(atom s, atom arg2, atom n)
	return c_func(curl_strnequalx, {s,arg2,n})
end function
--
export constant curl_mime_initx = define_c_func(dll, "+curl_mime_init",{C_POINTER}, C_POINTER)
export function curl_mime_init(atom easy)
	return c_func(curl_mime_initx, {easy})
end function
--
export constant curl_mime_freex = define_c_proc(dll, "+curl_mime_free",{C_POINTER})
export procedure curl_mime_free(atom mime)
	c_proc(curl_mime_freex, {mime})
end procedure
--
export constant curl_mime_addpartx = define_c_func(dll, "+curl_mime_addpart",{C_POINTER}, C_POINTER)
export function curl_mime_addpart(atom mime)
	return c_func(curl_mime_addpartx, {mime})
end function
--
constant C_CURLCODE = C_POINTER
export constant curl_mime_namex = define_c_func(dll, "+curl_mime_name",{C_POINTER, C_POINTER}, C_CURLCODE)
export function curl_mime_name(atom part, atom name)
	return c_func(curl_mime_namex, {part,name})
end function
--
export constant curl_mime_filenamex = define_c_func(dll, "+curl_mime_filename",{C_POINTER, C_POINTER}, C_CURLCODE)
export function curl_mime_filename(atom part, atom filename)
	return c_func(curl_mime_filenamex, {part,filename})
end function
--
export constant curl_mime_typex = define_c_func(dll, "+curl_mime_type",{C_POINTER, C_POINTER}, C_CURLCODE)
export function curl_mime_type(atom part, atom mimetype)
	return c_func(curl_mime_typex, {part,mimetype})
end function
--
export constant curl_mime_encoderx = define_c_func(dll, "+curl_mime_encoder",{C_POINTER, C_POINTER}, C_CURLCODE)
export function curl_mime_encoder(atom part, atom encoding)
	return c_func(curl_mime_encoderx, {part,encoding})
end function
--
export constant curl_mime_datax = define_c_func(dll, "+curl_mime_data",{C_POINTER, C_POINTER, C_SIZE_T}, C_CURLCODE)
export function curl_mime_data(atom part, atom data, atom datasize)
	return c_func(curl_mime_datax, {part,data,datasize})
end function
--
export constant curl_mime_filedatax = define_c_func(dll, "+curl_mime_filedata",{C_POINTER, C_POINTER}, C_CURLCODE)
export function curl_mime_filedata(atom part, atom filename)
	return c_func(curl_mime_filedatax, {part,filename})
end function
export constant C_CURL_OFF_T = C_POINTER
export constant C_CURL_READ_CALLBACK = C_POINTER
export constant C_CURL_SEEK_CALLBACK = C_POINTER
export constant C_CURL_FREE_CALLBACK = C_POINTER
--
export constant curl_mime_data_cbx = define_c_func(dll, "+curl_mime_data_cb",{C_POINTER, C_CURL_OFF_T, C_CURL_READ_CALLBACK, C_CURL_SEEK_CALLBACK, C_CURL_FREE_CALLBACK, C_POINTER}, C_CURLCODE)
export function curl_mime_data_cb(atom part, atom datasize, atom readfunc, atom seekfunc, atom freefunc, atom arg)
	return c_func(curl_mime_data_cbx, {part,datasize,readfunc,seekfunc,freefunc,arg})
end function
--
export constant curl_mime_subpartsx = define_c_func(dll, "+curl_mime_subparts",{C_POINTER, C_POINTER}, C_CURLCODE)
export function curl_mime_subparts(atom part, atom subparts)
	return c_func(curl_mime_subpartsx, {part,subparts})
end function
--
export constant curl_mime_headersx = define_c_func(dll, "+curl_mime_headers",{C_POINTER, C_POINTER, C_INT}, C_CURLCODE)
export function curl_mime_headers(atom part, atom headers, atom take_ownership)
	return c_func(curl_mime_headersx, {part,headers,take_ownership})
end function
--
constant C_CURLFORMCODE = C_POINTER
export constant curl_formaddx = define_c_func(dll, "+curl_formadd",{C_POINTER, C_POINTER}, C_CURLFORMCODE)
export function curl_formadd(atom httppost, atom last_post)
	return c_func(curl_formaddx, {httppost,last_post})
end function
export constant C_CURL_FORMGET_CALLBACK = C_POINTER
--
export constant curl_formgetx = define_c_func(dll, "+curl_formget",{C_POINTER, C_POINTER, C_CURL_FORMGET_CALLBACK}, C_INT)
export function curl_formget(atom form, atom arg, atom append)
	return c_func(curl_formgetx, {form,arg,append})
end function
--
export constant curl_formfreex = define_c_proc(dll, "+curl_formfree",{C_POINTER})
export procedure curl_formfree(atom form)
	c_proc(curl_formfreex, {form})
end procedure
--
export constant curl_getenvx = define_c_func(dll, "+curl_getenv",{C_POINTER}, C_POINTER)
export function curl_getenv(atom variable)
	return c_func(curl_getenvx, {variable})
end function
--
export constant curl_versionx = define_c_func(dll, "+curl_version",{}, C_POINTER)
export function curl_version()
	return c_func(curl_versionx, {})
end function
--
export constant curl_easy_escapex = define_c_func(dll, "+curl_easy_escape",{C_POINTER, C_POINTER, C_INT}, C_POINTER)
export function curl_easy_escape(atom handle, atom string, atom length)
	return c_func(curl_easy_escapex, {handle,string,length})
end function
--
export constant curl_escapex = define_c_func(dll, "+curl_escape",{C_POINTER, C_INT}, C_POINTER)
export function curl_escape(atom string, atom length)
	return c_func(curl_escapex, {string,length})
end function
--
export constant curl_easy_unescapex = define_c_func(dll, "+curl_easy_unescape",{C_POINTER, C_POINTER, C_INT, C_POINTER}, C_POINTER)
export function curl_easy_unescape(atom handle, atom string, atom length, atom outlength)
	return c_func(curl_easy_unescapex, {handle,string,length,outlength})
end function
--
export constant curl_unescapex = define_c_func(dll, "+curl_unescape",{C_POINTER, C_INT}, C_POINTER)
export function curl_unescape(atom string, atom length)
	return c_func(curl_unescapex, {string,length})
end function
--
export constant curl_freex = define_c_proc(dll, "+curl_free",{C_POINTER})
export procedure curl_free(atom p)
	c_proc(curl_freex, {p})
end procedure
--
export constant curl_global_initx = define_c_func(dll, "+curl_global_init",{C_LONG}, C_CURLCODE)
export function curl_global_init(atom flags)
	return c_func(curl_global_initx, {flags})
end function
export constant C_CURL_MALLOC_CALLBACK = C_POINTER
export constant C_CURL_REALLOC_CALLBACK = C_POINTER
export constant C_CURL_STRDUP_CALLBACK = C_POINTER
export constant C_CURL_CALLOC_CALLBACK = C_POINTER
--
export constant curl_global_init_memx = define_c_func(dll, "+curl_global_init_mem",{C_LONG, C_CURL_MALLOC_CALLBACK, C_CURL_FREE_CALLBACK, C_CURL_REALLOC_CALLBACK, C_CURL_STRDUP_CALLBACK, C_CURL_CALLOC_CALLBACK}, C_CURLCODE)
export function curl_global_init_mem(atom flags, atom m, atom f, atom r, atom s, atom c)
	return c_func(curl_global_init_memx, {flags,m,f,r,s,c})
end function
--
export constant curl_global_cleanupx = define_c_proc(dll, "+curl_global_cleanup",{})
export procedure curl_global_cleanup()
	c_proc(curl_global_cleanupx, {})
end procedure
export constant C_CURL_SSLBACKEND = C_POINTER
--
constant C_CURLSSLSET = C_POINTER
export constant curl_global_sslsetx = define_c_func(dll, "+curl_global_sslset",{C_CURL_SSLBACKEND, C_POINTER, C_POINTER}, C_CURLSSLSET)
export function curl_global_sslset(atom id, atom name, atom avail)
	return c_func(curl_global_sslsetx, {id,name,avail})
end function
--
export constant curl_slist_free_allx = define_c_proc(dll, "+curl_slist_free_all",{C_POINTER})
export procedure curl_slist_free_all(atom arg1)
	c_proc(curl_slist_free_allx, {arg1})
end procedure
--
constant C_TIME_T = C_POINTER
export constant curl_getdatex = define_c_func(dll, "+curl_getdate",{C_POINTER, C_POINTER}, C_TIME_T)
export function curl_getdate(atom p, atom unused)
	return c_func(curl_getdatex, {p,unused})
end function
--
export constant curl_share_initx = define_c_func(dll, "+curl_share_init",{}, C_POINTER)
export function curl_share_init()
	return c_func(curl_share_initx, {})
end function
export constant C_CURLSHOPTION = C_POINTER
--
constant C_CURLSHCODE = C_POINTER
export constant curl_share_setoptx = define_c_func(dll, "+curl_share_setopt",{C_POINTER, C_CURLSHOPTION}, C_CURLSHCODE)
export function curl_share_setopt(atom arg1, atom option)
	return c_func(curl_share_setoptx, {arg1,option})
end function
--
export constant curl_share_cleanupx = define_c_func(dll, "+curl_share_cleanup",{C_POINTER}, C_CURLSHCODE)
export function curl_share_cleanup(atom arg1)
	return c_func(curl_share_cleanupx, {arg1})
end function
export constant C_CURLVERSION = C_POINTER
--
export constant curl_version_infox = define_c_func(dll, "+curl_version_info",{C_CURLVERSION}, C_POINTER)
export function curl_version_info(atom CURLversion)
	return c_func(curl_version_infox, {CURLversion})
end function
--const 
export constant curl_easy_strerrorx = define_c_func(dll, "+curl_easy_strerror",{C_CURLCODE}, C_POINTER)
export function curl_easy_strerror(atom CURLcode)
	return c_func(curl_easy_strerrorx, {CURLcode})
end function
--const 
export constant curl_share_strerrorx = define_c_func(dll, "+curl_share_strerror",{C_CURLSHCODE}, C_POINTER)
export function curl_share_strerror(atom CURLSHcode)
	return c_func(curl_share_strerrorx, {CURLSHcode})
end function
--
export constant curl_easy_pausex = define_c_func(dll, "+curl_easy_pause",{C_POINTER, C_INT}, C_CURLCODE)
export function curl_easy_pause(atom handle, atom bitmask)
	return c_func(curl_easy_pausex, {handle,bitmask})
end function
