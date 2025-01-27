(define numeric-chars-alist '(
; Nd + Nl + No
(#x0030 . 0)
(#x0031 . 1)
(#x0032 . 2)
(#x0033 . 3)
(#x0034 . 4)
(#x0035 . 5)
(#x0036 . 6)
(#x0037 . 7)
(#x0038 . 8)
(#x0039 . 9)
(#x00B2 . #T)
(#x00B3 . #T)
(#x00B9 . #T)
(#x00BC . #T)
(#x00BD . #T)
(#x00BE . #T)
(#x0660 . 0)
(#x0661 . 1)
(#x0662 . 2)
(#x0663 . 3)
(#x0664 . 4)
(#x0665 . 5)
(#x0666 . 6)
(#x0667 . 7)
(#x0668 . 8)
(#x0669 . 9)
(#x06F0 . 0)
(#x06F1 . 1)
(#x06F2 . 2)
(#x06F3 . 3)
(#x06F4 . 4)
(#x06F5 . 5)
(#x06F6 . 6)
(#x06F7 . 7)
(#x06F8 . 8)
(#x06F9 . 9)
(#x07C0 . 0)
(#x07C1 . 1)
(#x07C2 . 2)
(#x07C3 . 3)
(#x07C4 . 4)
(#x07C5 . 5)
(#x07C6 . 6)
(#x07C7 . 7)
(#x07C8 . 8)
(#x07C9 . 9)
(#x0966 . 0)
(#x0967 . 1)
(#x0968 . 2)
(#x0969 . 3)
(#x096A . 4)
(#x096B . 5)
(#x096C . 6)
(#x096D . 7)
(#x096E . 8)
(#x096F . 9)
(#x09E6 . 0)
(#x09E7 . 1)
(#x09E8 . 2)
(#x09E9 . 3)
(#x09EA . 4)
(#x09EB . 5)
(#x09EC . 6)
(#x09ED . 7)
(#x09EE . 8)
(#x09EF . 9)
(#x09F4 . #T)
(#x09F5 . #T)
(#x09F6 . #T)
(#x09F7 . #T)
(#x09F8 . #T)
(#x09F9 . #T)
(#x0A66 . 0)
(#x0A67 . 1)
(#x0A68 . 2)
(#x0A69 . 3)
(#x0A6A . 4)
(#x0A6B . 5)
(#x0A6C . 6)
(#x0A6D . 7)
(#x0A6E . 8)
(#x0A6F . 9)
(#x0AE6 . 0)
(#x0AE7 . 1)
(#x0AE8 . 2)
(#x0AE9 . 3)
(#x0AEA . 4)
(#x0AEB . 5)
(#x0AEC . 6)
(#x0AED . 7)
(#x0AEE . 8)
(#x0AEF . 9)
(#x0B66 . 0)
(#x0B67 . 1)
(#x0B68 . 2)
(#x0B69 . 3)
(#x0B6A . 4)
(#x0B6B . 5)
(#x0B6C . 6)
(#x0B6D . 7)
(#x0B6E . 8)
(#x0B6F . 9)
(#x0B72 . #T)
(#x0B73 . #T)
(#x0B74 . #T)
(#x0B75 . #T)
(#x0B76 . #T)
(#x0B77 . #T)
(#x0BE6 . 0)
(#x0BE7 . 1)
(#x0BE8 . 2)
(#x0BE9 . 3)
(#x0BEA . 4)
(#x0BEB . 5)
(#x0BEC . 6)
(#x0BED . 7)
(#x0BEE . 8)
(#x0BEF . 9)
(#x0BF0 . #T)
(#x0BF1 . #T)
(#x0BF2 . #T)
(#x0C66 . 0)
(#x0C67 . 1)
(#x0C68 . 2)
(#x0C69 . 3)
(#x0C6A . 4)
(#x0C6B . 5)
(#x0C6C . 6)
(#x0C6D . 7)
(#x0C6E . 8)
(#x0C6F . 9)
(#x0C78 . 0)
(#x0C79 . 1)
(#x0C7A . 2)
(#x0C7B . 3)
(#x0C7C . 1)
(#x0C7D . 2)
(#x0C7E . 3)
(#x0CE6 . 0)
(#x0CE7 . 1)
(#x0CE8 . 2)
(#x0CE9 . 3)
(#x0CEA . 4)
(#x0CEB . 5)
(#x0CEC . 6)
(#x0CED . 7)
(#x0CEE . 8)
(#x0CEF . 9)
(#x0D58 . #T)
(#x0D59 . #T)
(#x0D5A . #T)
(#x0D5B . #T)
(#x0D5C . #T)
(#x0D5D . #T)
(#x0D5E . #T)
(#x0D66 . 0)
(#x0D67 . 1)
(#x0D68 . 2)
(#x0D69 . 3)
(#x0D6A . 4)
(#x0D6B . 5)
(#x0D6C . 6)
(#x0D6D . 7)
(#x0D6E . 8)
(#x0D6F . 9)
(#x0D70 . #T)
(#x0D71 . #T)
(#x0D72 . #T)
(#x0D73 . #T)
(#x0D74 . #T)
(#x0D75 . #T)
(#x0D76 . #T)
(#x0D77 . #T)
(#x0D78 . #T)
(#x0DE6 . 0)
(#x0DE7 . 1)
(#x0DE8 . 2)
(#x0DE9 . 3)
(#x0DEA . 4)
(#x0DEB . 5)
(#x0DEC . 6)
(#x0DED . 7)
(#x0DEE . 8)
(#x0DEF . 9)
(#x0E50 . 0)
(#x0E51 . 1)
(#x0E52 . 2)
(#x0E53 . 3)
(#x0E54 . 4)
(#x0E55 . 5)
(#x0E56 . 6)
(#x0E57 . 7)
(#x0E58 . 8)
(#x0E59 . 9)
(#x0ED0 . 0)
(#x0ED1 . 1)
(#x0ED2 . 2)
(#x0ED3 . 3)
(#x0ED4 . 4)
(#x0ED5 . 5)
(#x0ED6 . 6)
(#x0ED7 . 7)
(#x0ED8 . 8)
(#x0ED9 . 9)
(#x0F20 . 0)
(#x0F21 . 1)
(#x0F22 . 2)
(#x0F23 . 3)
(#x0F24 . 4)
(#x0F25 . 5)
(#x0F26 . 6)
(#x0F27 . 7)
(#x0F28 . 8)
(#x0F29 . 9)
(#x0F2A . #T)
(#x0F2B . #T)
(#x0F2C . #T)
(#x0F2D . #T)
(#x0F2E . #T)
(#x0F2F . #T)
(#x0F30 . #T)
(#x0F31 . #T)
(#x0F32 . #T)
(#x0F33 . #T)
(#x1040 . 0)
(#x1041 . 1)
(#x1042 . 2)
(#x1043 . 3)
(#x1044 . 4)
(#x1045 . 5)
(#x1046 . 6)
(#x1047 . 7)
(#x1048 . 8)
(#x1049 . 9)
(#x1090 . 0)
(#x1091 . 1)
(#x1092 . 2)
(#x1093 . 3)
(#x1094 . 4)
(#x1095 . 5)
(#x1096 . 6)
(#x1097 . 7)
(#x1098 . 8)
(#x1099 . 9)
(#x1369 . 1)
(#x136A . 2)
(#x136B . 3)
(#x136C . 4)
(#x136D . 5)
(#x136E . 6)
(#x136F . 7)
(#x1370 . 8)
(#x1371 . 9)
(#x1372 . #T)
(#x1373 . #T)
(#x1374 . #T)
(#x1375 . #T)
(#x1376 . #T)
(#x1377 . #T)
(#x1378 . #T)
(#x1379 . #T)
(#x137A . #T)
(#x137B . #T)
(#x137C . #T)
(#x16EE . #T)
(#x16EF . #T)
(#x16F0 . #T)
(#x17E0 . 0)
(#x17E1 . 1)
(#x17E2 . 2)
(#x17E3 . 3)
(#x17E4 . 4)
(#x17E5 . 5)
(#x17E6 . 6)
(#x17E7 . 7)
(#x17E8 . 8)
(#x17E9 . 9)
(#x17F0 . #T)
(#x17F1 . #T)
(#x17F2 . #T)
(#x17F3 . #T)
(#x17F4 . #T)
(#x17F5 . #T)
(#x17F6 . #T)
(#x17F7 . #T)
(#x17F8 . #T)
(#x17F9 . #T)
(#x1810 . 0)
(#x1811 . 1)
(#x1812 . 2)
(#x1813 . 3)
(#x1814 . 4)
(#x1815 . 5)
(#x1816 . 6)
(#x1817 . 7)
(#x1818 . 8)
(#x1819 . 9)
(#x1946 . 0)
(#x1947 . 1)
(#x1948 . 2)
(#x1949 . 3)
(#x194A . 4)
(#x194B . 5)
(#x194C . 6)
(#x194D . 7)
(#x194E . 8)
(#x194F . 9)
(#x19D0 . 0)
(#x19D1 . 1)
(#x19D2 . 2)
(#x19D3 . 3)
(#x19D4 . 4)
(#x19D5 . 5)
(#x19D6 . 6)
(#x19D7 . 7)
(#x19D8 . 8)
(#x19D9 . 9)
(#x19DA . 1)
(#x1A80 . 0)
(#x1A81 . 1)
(#x1A82 . 2)
(#x1A83 . 3)
(#x1A84 . 4)
(#x1A85 . 5)
(#x1A86 . 6)
(#x1A87 . 7)
(#x1A88 . 8)
(#x1A89 . 9)
(#x1A90 . 0)
(#x1A91 . 1)
(#x1A92 . 2)
(#x1A93 . 3)
(#x1A94 . 4)
(#x1A95 . 5)
(#x1A96 . 6)
(#x1A97 . 7)
(#x1A98 . 8)
(#x1A99 . 9)
(#x1B50 . 0)
(#x1B51 . 1)
(#x1B52 . 2)
(#x1B53 . 3)
(#x1B54 . 4)
(#x1B55 . 5)
(#x1B56 . 6)
(#x1B57 . 7)
(#x1B58 . 8)
(#x1B59 . 9)
(#x1BB0 . 0)
(#x1BB1 . 1)
(#x1BB2 . 2)
(#x1BB3 . 3)
(#x1BB4 . 4)
(#x1BB5 . 5)
(#x1BB6 . 6)
(#x1BB7 . 7)
(#x1BB8 . 8)
(#x1BB9 . 9)
(#x1C40 . 0)
(#x1C41 . 1)
(#x1C42 . 2)
(#x1C43 . 3)
(#x1C44 . 4)
(#x1C45 . 5)
(#x1C46 . 6)
(#x1C47 . 7)
(#x1C48 . 8)
(#x1C49 . 9)
(#x1C50 . 0)
(#x1C51 . 1)
(#x1C52 . 2)
(#x1C53 . 3)
(#x1C54 . 4)
(#x1C55 . 5)
(#x1C56 . 6)
(#x1C57 . 7)
(#x1C58 . 8)
(#x1C59 . 9)
(#x2070 . #T)
(#x2074 . #T)
(#x2075 . #T)
(#x2076 . #T)
(#x2077 . #T)
(#x2078 . #T)
(#x2079 . #T)
(#x2080 . #T)
(#x2081 . #T)
(#x2082 . #T)
(#x2083 . #T)
(#x2084 . #T)
(#x2085 . #T)
(#x2086 . #T)
(#x2087 . #T)
(#x2088 . #T)
(#x2089 . #T)
(#x2150 . #T)
(#x2151 . #T)
(#x2152 . #T)
(#x2153 . #T)
(#x2154 . #T)
(#x2155 . #T)
(#x2156 . #T)
(#x2157 . #T)
(#x2158 . #T)
(#x2159 . #T)
(#x215A . #T)
(#x215B . #T)
(#x215C . #T)
(#x215D . #T)
(#x215E . #T)
(#x215F . #T)
(#x2160 . #T)
(#x2161 . #T)
(#x2162 . #T)
(#x2163 . #T)
(#x2164 . #T)
(#x2165 . #T)
(#x2166 . #T)
(#x2167 . #T)
(#x2168 . #T)
(#x2169 . #T)
(#x216A . #T)
(#x216B . #T)
(#x216C . #T)
(#x216D . #T)
(#x216E . #T)
(#x216F . #T)
(#x2170 . #T)
(#x2171 . #T)
(#x2172 . #T)
(#x2173 . #T)
(#x2174 . #T)
(#x2175 . #T)
(#x2176 . #T)
(#x2177 . #T)
(#x2178 . #T)
(#x2179 . #T)
(#x217A . #T)
(#x217B . #T)
(#x217C . #T)
(#x217D . #T)
(#x217E . #T)
(#x217F . #T)
(#x2180 . #T)
(#x2181 . #T)
(#x2182 . #T)
(#x2185 . #T)
(#x2186 . #T)
(#x2187 . #T)
(#x2188 . #T)
(#x2189 . #T)
(#x2460 . 1)
(#x2461 . 2)
(#x2462 . 3)
(#x2463 . 4)
(#x2464 . 5)
(#x2465 . 6)
(#x2466 . 7)
(#x2467 . 8)
(#x2468 . 9)
(#x2469 . #T)
(#x246A . #T)
(#x246B . #T)
(#x246C . #T)
(#x246D . #T)
(#x246E . #T)
(#x246F . #T)
(#x2470 . #T)
(#x2471 . #T)
(#x2472 . #T)
(#x2473 . #T)
(#x2474 . 1)
(#x2475 . 2)
(#x2476 . 3)
(#x2477 . 4)
(#x2478 . 5)
(#x2479 . 6)
(#x247A . 7)
(#x247B . 8)
(#x247C . 9)
(#x247D . #T)
(#x247E . #T)
(#x247F . #T)
(#x2480 . #T)
(#x2481 . #T)
(#x2482 . #T)
(#x2483 . #T)
(#x2484 . #T)
(#x2485 . #T)
(#x2486 . #T)
(#x2487 . #T)
(#x2488 . 1)
(#x2489 . 2)
(#x248A . 3)
(#x248B . 4)
(#x248C . 5)
(#x248D . 6)
(#x248E . 7)
(#x248F . 8)
(#x2490 . 9)
(#x2491 . #T)
(#x2492 . #T)
(#x2493 . #T)
(#x2494 . #T)
(#x2495 . #T)
(#x2496 . #T)
(#x2497 . #T)
(#x2498 . #T)
(#x2499 . #T)
(#x249A . #T)
(#x249B . #T)
(#x24EA . 0)
(#x24EB . #T)
(#x24EC . #T)
(#x24ED . #T)
(#x24EE . #T)
(#x24EF . #T)
(#x24F0 . #T)
(#x24F1 . #T)
(#x24F2 . #T)
(#x24F3 . #T)
(#x24F4 . #T)
(#x24F5 . 1)
(#x24F6 . 2)
(#x24F7 . 3)
(#x24F8 . 4)
(#x24F9 . 5)
(#x24FA . 6)
(#x24FB . 7)
(#x24FC . 8)
(#x24FD . 9)
(#x24FE . #T)
(#x24FF . 0)
(#x2776 . 1)
(#x2777 . 2)
(#x2778 . 3)
(#x2779 . 4)
(#x277A . 5)
(#x277B . 6)
(#x277C . 7)
(#x277D . 8)
(#x277E . 9)
(#x277F . #T)
(#x2780 . 1)
(#x2781 . 2)
(#x2782 . 3)
(#x2783 . 4)
(#x2784 . 5)
(#x2785 . 6)
(#x2786 . 7)
(#x2787 . 8)
(#x2788 . 9)
(#x2789 . #T)
(#x278A . 1)
(#x278B . 2)
(#x278C . 3)
(#x278D . 4)
(#x278E . 5)
(#x278F . 6)
(#x2790 . 7)
(#x2791 . 8)
(#x2792 . 9)
(#x2793 . #T)
(#x2CFD . #T)
(#x3007 . #T)
(#x3021 . #T)
(#x3022 . #T)
(#x3023 . #T)
(#x3024 . #T)
(#x3025 . #T)
(#x3026 . #T)
(#x3027 . #T)
(#x3028 . #T)
(#x3029 . #T)
(#x3038 . #T)
(#x3039 . #T)
(#x303A . #T)
(#x3192 . #T)
(#x3193 . #T)
(#x3194 . #T)
(#x3195 . #T)
(#x3220 . #T)
(#x3221 . #T)
(#x3222 . #T)
(#x3223 . #T)
(#x3224 . #T)
(#x3225 . #T)
(#x3226 . #T)
(#x3227 . #T)
(#x3228 . #T)
(#x3229 . #T)
(#x3248 . #T)
(#x3249 . #T)
(#x324A . #T)
(#x324B . #T)
(#x324C . #T)
(#x324D . #T)
(#x324E . #T)
(#x324F . #T)
(#x3251 . #T)
(#x3252 . #T)
(#x3253 . #T)
(#x3254 . #T)
(#x3255 . #T)
(#x3256 . #T)
(#x3257 . #T)
(#x3258 . #T)
(#x3259 . #T)
(#x325A . #T)
(#x325B . #T)
(#x325C . #T)
(#x325D . #T)
(#x325E . #T)
(#x325F . #T)
(#x3280 . #T)
(#x3281 . #T)
(#x3282 . #T)
(#x3283 . #T)
(#x3284 . #T)
(#x3285 . #T)
(#x3286 . #T)
(#x3287 . #T)
(#x3288 . #T)
(#x3289 . #T)
(#x32B1 . #T)
(#x32B2 . #T)
(#x32B3 . #T)
(#x32B4 . #T)
(#x32B5 . #T)
(#x32B6 . #T)
(#x32B7 . #T)
(#x32B8 . #T)
(#x32B9 . #T)
(#x32BA . #T)
(#x32BB . #T)
(#x32BC . #T)
(#x32BD . #T)
(#x32BE . #T)
(#x32BF . #T)
(#xA620 . 0)
(#xA621 . 1)
(#xA622 . 2)
(#xA623 . 3)
(#xA624 . 4)
(#xA625 . 5)
(#xA626 . 6)
(#xA627 . 7)
(#xA628 . 8)
(#xA629 . 9)
(#xA6E6 . #T)
(#xA6E7 . #T)
(#xA6E8 . #T)
(#xA6E9 . #T)
(#xA6EA . #T)
(#xA6EB . #T)
(#xA6EC . #T)
(#xA6ED . #T)
(#xA6EE . #T)
(#xA6EF . #T)
(#xA830 . #T)
(#xA831 . #T)
(#xA832 . #T)
(#xA833 . #T)
(#xA834 . #T)
(#xA835 . #T)
(#xA8D0 . 0)
(#xA8D1 . 1)
(#xA8D2 . 2)
(#xA8D3 . 3)
(#xA8D4 . 4)
(#xA8D5 . 5)
(#xA8D6 . 6)
(#xA8D7 . 7)
(#xA8D8 . 8)
(#xA8D9 . 9)
(#xA900 . 0)
(#xA901 . 1)
(#xA902 . 2)
(#xA903 . 3)
(#xA904 . 4)
(#xA905 . 5)
(#xA906 . 6)
(#xA907 . 7)
(#xA908 . 8)
(#xA909 . 9)
(#xA9D0 . 0)
(#xA9D1 . 1)
(#xA9D2 . 2)
(#xA9D3 . 3)
(#xA9D4 . 4)
(#xA9D5 . 5)
(#xA9D6 . 6)
(#xA9D7 . 7)
(#xA9D8 . 8)
(#xA9D9 . 9)
(#xA9F0 . 0)
(#xA9F1 . 1)
(#xA9F2 . 2)
(#xA9F3 . 3)
(#xA9F4 . 4)
(#xA9F5 . 5)
(#xA9F6 . 6)
(#xA9F7 . 7)
(#xA9F8 . 8)
(#xA9F9 . 9)
(#xAA50 . 0)
(#xAA51 . 1)
(#xAA52 . 2)
(#xAA53 . 3)
(#xAA54 . 4)
(#xAA55 . 5)
(#xAA56 . 6)
(#xAA57 . 7)
(#xAA58 . 8)
(#xAA59 . 9)
(#xABF0 . 0)
(#xABF1 . 1)
(#xABF2 . 2)
(#xABF3 . 3)
(#xABF4 . 4)
(#xABF5 . 5)
(#xABF6 . 6)
(#xABF7 . 7)
(#xABF8 . 8)
(#xABF9 . 9)
(#xFF10 . 0)
(#xFF11 . 1)
(#xFF12 . 2)
(#xFF13 . 3)
(#xFF14 . 4)
(#xFF15 . 5)
(#xFF16 . 6)
(#xFF17 . 7)
(#xFF18 . 8)
(#xFF19 . 9)
(#x10107 . #T)
(#x10108 . #T)
(#x10109 . #T)
(#x1010A . #T)
(#x1010B . #T)
(#x1010C . #T)
(#x1010D . #T)
(#x1010E . #T)
(#x1010F . #T)
(#x10110 . #T)
(#x10111 . #T)
(#x10112 . #T)
(#x10113 . #T)
(#x10114 . #T)
(#x10115 . #T)
(#x10116 . #T)
(#x10117 . #T)
(#x10118 . #T)
(#x10119 . #T)
(#x1011A . #T)
(#x1011B . #T)
(#x1011C . #T)
(#x1011D . #T)
(#x1011E . #T)
(#x1011F . #T)
(#x10120 . #T)
(#x10121 . #T)
(#x10122 . #T)
(#x10123 . #T)
(#x10124 . #T)
(#x10125 . #T)
(#x10126 . #T)
(#x10127 . #T)
(#x10128 . #T)
(#x10129 . #T)
(#x1012A . #T)
(#x1012B . #T)
(#x1012C . #T)
(#x1012D . #T)
(#x1012E . #T)
(#x1012F . #T)
(#x10130 . #T)
(#x10131 . #T)
(#x10132 . #T)
(#x10133 . #T)
(#x10140 . #T)
(#x10141 . #T)
(#x10142 . #T)
(#x10143 . #T)
(#x10144 . #T)
(#x10145 . #T)
(#x10146 . #T)
(#x10147 . #T)
(#x10148 . #T)
(#x10149 . #T)
(#x1014A . #T)
(#x1014B . #T)
(#x1014C . #T)
(#x1014D . #T)
(#x1014E . #T)
(#x1014F . #T)
(#x10150 . #T)
(#x10151 . #T)
(#x10152 . #T)
(#x10153 . #T)
(#x10154 . #T)
(#x10155 . #T)
(#x10156 . #T)
(#x10157 . #T)
(#x10158 . #T)
(#x10159 . #T)
(#x1015A . #T)
(#x1015B . #T)
(#x1015C . #T)
(#x1015D . #T)
(#x1015E . #T)
(#x1015F . #T)
(#x10160 . #T)
(#x10161 . #T)
(#x10162 . #T)
(#x10163 . #T)
(#x10164 . #T)
(#x10165 . #T)
(#x10166 . #T)
(#x10167 . #T)
(#x10168 . #T)
(#x10169 . #T)
(#x1016A . #T)
(#x1016B . #T)
(#x1016C . #T)
(#x1016D . #T)
(#x1016E . #T)
(#x1016F . #T)
(#x10170 . #T)
(#x10171 . #T)
(#x10172 . #T)
(#x10173 . #T)
(#x10174 . #T)
(#x10175 . #T)
(#x10176 . #T)
(#x10177 . #T)
(#x10178 . #T)
(#x1018A . #T)
(#x1018B . #T)
(#x102E1 . 1)
(#x102E2 . 2)
(#x102E3 . 3)
(#x102E4 . 4)
(#x102E5 . 5)
(#x102E6 . 6)
(#x102E7 . 7)
(#x102E8 . 8)
(#x102E9 . 9)
(#x102EA . #T)
(#x102EB . #T)
(#x102EC . #T)
(#x102ED . #T)
(#x102EE . #T)
(#x102EF . #T)
(#x102F0 . #T)
(#x102F1 . #T)
(#x102F2 . #T)
(#x102F3 . #T)
(#x102F4 . #T)
(#x102F5 . #T)
(#x102F6 . #T)
(#x102F7 . #T)
(#x102F8 . #T)
(#x102F9 . #T)
(#x102FA . #T)
(#x102FB . #T)
(#x10320 . #T)
(#x10321 . #T)
(#x10322 . #T)
(#x10323 . #T)
(#x10341 . #T)
(#x1034A . #T)
(#x103D1 . #T)
(#x103D2 . #T)
(#x103D3 . #T)
(#x103D4 . #T)
(#x103D5 . #T)
(#x104A0 . 0)
(#x104A1 . 1)
(#x104A2 . 2)
(#x104A3 . 3)
(#x104A4 . 4)
(#x104A5 . 5)
(#x104A6 . 6)
(#x104A7 . 7)
(#x104A8 . 8)
(#x104A9 . 9)
(#x10858 . #T)
(#x10859 . #T)
(#x1085A . #T)
(#x1085B . #T)
(#x1085C . #T)
(#x1085D . #T)
(#x1085E . #T)
(#x1085F . #T)
(#x10879 . #T)
(#x1087A . #T)
(#x1087B . #T)
(#x1087C . #T)
(#x1087D . #T)
(#x1087E . #T)
(#x1087F . #T)
(#x108A7 . #T)
(#x108A8 . #T)
(#x108A9 . #T)
(#x108AA . #T)
(#x108AB . #T)
(#x108AC . #T)
(#x108AD . #T)
(#x108AE . #T)
(#x108AF . #T)
(#x108FB . #T)
(#x108FC . #T)
(#x108FD . #T)
(#x108FE . #T)
(#x108FF . #T)
(#x10916 . #T)
(#x10917 . #T)
(#x10918 . #T)
(#x10919 . #T)
(#x1091A . #T)
(#x1091B . #T)
(#x109BC . #T)
(#x109BD . #T)
(#x109C0 . #T)
(#x109C1 . #T)
(#x109C2 . #T)
(#x109C3 . #T)
(#x109C4 . #T)
(#x109C5 . #T)
(#x109C6 . #T)
(#x109C7 . #T)
(#x109C8 . #T)
(#x109C9 . #T)
(#x109CA . #T)
(#x109CB . #T)
(#x109CC . #T)
(#x109CD . #T)
(#x109CE . #T)
(#x109CF . #T)
(#x109D2 . #T)
(#x109D3 . #T)
(#x109D4 . #T)
(#x109D5 . #T)
(#x109D6 . #T)
(#x109D7 . #T)
(#x109D8 . #T)
(#x109D9 . #T)
(#x109DA . #T)
(#x109DB . #T)
(#x109DC . #T)
(#x109DD . #T)
(#x109DE . #T)
(#x109DF . #T)
(#x109E0 . #T)
(#x109E1 . #T)
(#x109E2 . #T)
(#x109E3 . #T)
(#x109E4 . #T)
(#x109E5 . #T)
(#x109E6 . #T)
(#x109E7 . #T)
(#x109E8 . #T)
(#x109E9 . #T)
(#x109EA . #T)
(#x109EB . #T)
(#x109EC . #T)
(#x109ED . #T)
(#x109EE . #T)
(#x109EF . #T)
(#x109F0 . #T)
(#x109F1 . #T)
(#x109F2 . #T)
(#x109F3 . #T)
(#x109F4 . #T)
(#x109F5 . #T)
(#x109F6 . #T)
(#x109F7 . #T)
(#x109F8 . #T)
(#x109F9 . #T)
(#x109FA . #T)
(#x109FB . #T)
(#x109FC . #T)
(#x109FD . #T)
(#x109FE . #T)
(#x109FF . #T)
(#x10A40 . 1)
(#x10A41 . 2)
(#x10A42 . 3)
(#x10A43 . 4)
(#x10A44 . #T)
(#x10A45 . #T)
(#x10A46 . #T)
(#x10A47 . #T)
(#x10A48 . #T)
(#x10A7D . #T)
(#x10A7E . #T)
(#x10A9D . #T)
(#x10A9E . #T)
(#x10A9F . #T)
(#x10AEB . #T)
(#x10AEC . #T)
(#x10AED . #T)
(#x10AEE . #T)
(#x10AEF . #T)
(#x10B58 . #T)
(#x10B59 . #T)
(#x10B5A . #T)
(#x10B5B . #T)
(#x10B5C . #T)
(#x10B5D . #T)
(#x10B5E . #T)
(#x10B5F . #T)
(#x10B78 . #T)
(#x10B79 . #T)
(#x10B7A . #T)
(#x10B7B . #T)
(#x10B7C . #T)
(#x10B7D . #T)
(#x10B7E . #T)
(#x10B7F . #T)
(#x10BA9 . #T)
(#x10BAA . #T)
(#x10BAB . #T)
(#x10BAC . #T)
(#x10BAD . #T)
(#x10BAE . #T)
(#x10BAF . #T)
(#x10CFA . #T)
(#x10CFB . #T)
(#x10CFC . #T)
(#x10CFD . #T)
(#x10CFE . #T)
(#x10CFF . #T)
(#x10D30 . 0)
(#x10D31 . 1)
(#x10D32 . 2)
(#x10D33 . 3)
(#x10D34 . 4)
(#x10D35 . 5)
(#x10D36 . 6)
(#x10D37 . 7)
(#x10D38 . 8)
(#x10D39 . 9)
(#x10E60 . 1)
(#x10E61 . 2)
(#x10E62 . 3)
(#x10E63 . 4)
(#x10E64 . 5)
(#x10E65 . 6)
(#x10E66 . 7)
(#x10E67 . 8)
(#x10E68 . 9)
(#x10E69 . #T)
(#x10E6A . #T)
(#x10E6B . #T)
(#x10E6C . #T)
(#x10E6D . #T)
(#x10E6E . #T)
(#x10E6F . #T)
(#x10E70 . #T)
(#x10E71 . #T)
(#x10E72 . #T)
(#x10E73 . #T)
(#x10E74 . #T)
(#x10E75 . #T)
(#x10E76 . #T)
(#x10E77 . #T)
(#x10E78 . #T)
(#x10E79 . #T)
(#x10E7A . #T)
(#x10E7B . #T)
(#x10E7C . #T)
(#x10E7D . #T)
(#x10E7E . #T)
(#x10F1D . #T)
(#x10F1E . #T)
(#x10F1F . #T)
(#x10F20 . #T)
(#x10F21 . #T)
(#x10F22 . #T)
(#x10F23 . #T)
(#x10F24 . #T)
(#x10F25 . #T)
(#x10F26 . #T)
(#x10F51 . #T)
(#x10F52 . #T)
(#x10F53 . #T)
(#x10F54 . #T)
(#x10FC5 . #T)
(#x10FC6 . #T)
(#x10FC7 . #T)
(#x10FC8 . #T)
(#x10FC9 . #T)
(#x10FCA . #T)
(#x10FCB . #T)
(#x11052 . #T)
(#x11053 . #T)
(#x11054 . #T)
(#x11055 . #T)
(#x11056 . #T)
(#x11057 . #T)
(#x11058 . #T)
(#x11059 . #T)
(#x1105A . #T)
(#x1105B . #T)
(#x1105C . #T)
(#x1105D . #T)
(#x1105E . #T)
(#x1105F . #T)
(#x11060 . #T)
(#x11061 . #T)
(#x11062 . #T)
(#x11063 . #T)
(#x11064 . #T)
(#x11065 . #T)
(#x11066 . 0)
(#x11067 . 1)
(#x11068 . 2)
(#x11069 . 3)
(#x1106A . 4)
(#x1106B . 5)
(#x1106C . 6)
(#x1106D . 7)
(#x1106E . 8)
(#x1106F . 9)
(#x110F0 . 0)
(#x110F1 . 1)
(#x110F2 . 2)
(#x110F3 . 3)
(#x110F4 . 4)
(#x110F5 . 5)
(#x110F6 . 6)
(#x110F7 . 7)
(#x110F8 . 8)
(#x110F9 . 9)
(#x11136 . 0)
(#x11137 . 1)
(#x11138 . 2)
(#x11139 . 3)
(#x1113A . 4)
(#x1113B . 5)
(#x1113C . 6)
(#x1113D . 7)
(#x1113E . 8)
(#x1113F . 9)
(#x111D0 . 0)
(#x111D1 . 1)
(#x111D2 . 2)
(#x111D3 . 3)
(#x111D4 . 4)
(#x111D5 . 5)
(#x111D6 . 6)
(#x111D7 . 7)
(#x111D8 . 8)
(#x111D9 . 9)
(#x111E1 . 1)
(#x111E2 . 2)
(#x111E3 . 3)
(#x111E4 . 4)
(#x111E5 . 5)
(#x111E6 . 6)
(#x111E7 . 7)
(#x111E8 . 8)
(#x111E9 . 9)
(#x111EA . #T)
(#x111EB . #T)
(#x111EC . #T)
(#x111ED . #T)
(#x111EE . #T)
(#x111EF . #T)
(#x111F0 . #T)
(#x111F1 . #T)
(#x111F2 . #T)
(#x111F3 . #T)
(#x111F4 . #T)
(#x112F0 . 0)
(#x112F1 . 1)
(#x112F2 . 2)
(#x112F3 . 3)
(#x112F4 . 4)
(#x112F5 . 5)
(#x112F6 . 6)
(#x112F7 . 7)
(#x112F8 . 8)
(#x112F9 . 9)
(#x11450 . 0)
(#x11451 . 1)
(#x11452 . 2)
(#x11453 . 3)
(#x11454 . 4)
(#x11455 . 5)
(#x11456 . 6)
(#x11457 . 7)
(#x11458 . 8)
(#x11459 . 9)
(#x114D0 . 0)
(#x114D1 . 1)
(#x114D2 . 2)
(#x114D3 . 3)
(#x114D4 . 4)
(#x114D5 . 5)
(#x114D6 . 6)
(#x114D7 . 7)
(#x114D8 . 8)
(#x114D9 . 9)
(#x11650 . 0)
(#x11651 . 1)
(#x11652 . 2)
(#x11653 . 3)
(#x11654 . 4)
(#x11655 . 5)
(#x11656 . 6)
(#x11657 . 7)
(#x11658 . 8)
(#x11659 . 9)
(#x116C0 . 0)
(#x116C1 . 1)
(#x116C2 . 2)
(#x116C3 . 3)
(#x116C4 . 4)
(#x116C5 . 5)
(#x116C6 . 6)
(#x116C7 . 7)
(#x116C8 . 8)
(#x116C9 . 9)
(#x11730 . 0)
(#x11731 . 1)
(#x11732 . 2)
(#x11733 . 3)
(#x11734 . 4)
(#x11735 . 5)
(#x11736 . 6)
(#x11737 . 7)
(#x11738 . 8)
(#x11739 . 9)
(#x1173A . #T)
(#x1173B . #T)
(#x118E0 . 0)
(#x118E1 . 1)
(#x118E2 . 2)
(#x118E3 . 3)
(#x118E4 . 4)
(#x118E5 . 5)
(#x118E6 . 6)
(#x118E7 . 7)
(#x118E8 . 8)
(#x118E9 . 9)
(#x118EA . #T)
(#x118EB . #T)
(#x118EC . #T)
(#x118ED . #T)
(#x118EE . #T)
(#x118EF . #T)
(#x118F0 . #T)
(#x118F1 . #T)
(#x118F2 . #T)
(#x11950 . 0)
(#x11951 . 1)
(#x11952 . 2)
(#x11953 . 3)
(#x11954 . 4)
(#x11955 . 5)
(#x11956 . 6)
(#x11957 . 7)
(#x11958 . 8)
(#x11959 . 9)
(#x11C50 . 0)
(#x11C51 . 1)
(#x11C52 . 2)
(#x11C53 . 3)
(#x11C54 . 4)
(#x11C55 . 5)
(#x11C56 . 6)
(#x11C57 . 7)
(#x11C58 . 8)
(#x11C59 . 9)
(#x11C5A . #T)
(#x11C5B . #T)
(#x11C5C . #T)
(#x11C5D . #T)
(#x11C5E . #T)
(#x11C5F . #T)
(#x11C60 . #T)
(#x11C61 . #T)
(#x11C62 . #T)
(#x11C63 . #T)
(#x11C64 . #T)
(#x11C65 . #T)
(#x11C66 . #T)
(#x11C67 . #T)
(#x11C68 . #T)
(#x11C69 . #T)
(#x11C6A . #T)
(#x11C6B . #T)
(#x11C6C . #T)
(#x11D50 . 0)
(#x11D51 . 1)
(#x11D52 . 2)
(#x11D53 . 3)
(#x11D54 . 4)
(#x11D55 . 5)
(#x11D56 . 6)
(#x11D57 . 7)
(#x11D58 . 8)
(#x11D59 . 9)
(#x11DA0 . 0)
(#x11DA1 . 1)
(#x11DA2 . 2)
(#x11DA3 . 3)
(#x11DA4 . 4)
(#x11DA5 . 5)
(#x11DA6 . 6)
(#x11DA7 . 7)
(#x11DA8 . 8)
(#x11DA9 . 9)
(#x11FC0 . #T)
(#x11FC1 . #T)
(#x11FC2 . #T)
(#x11FC3 . #T)
(#x11FC4 . #T)
(#x11FC5 . #T)
(#x11FC6 . #T)
(#x11FC7 . #T)
(#x11FC8 . #T)
(#x11FC9 . #T)
(#x11FCA . #T)
(#x11FCB . #T)
(#x11FCC . #T)
(#x11FCD . #T)
(#x11FCE . #T)
(#x11FCF . #T)
(#x11FD0 . #T)
(#x11FD1 . #T)
(#x11FD2 . #T)
(#x11FD3 . #T)
(#x11FD4 . #T)
(#x12400 . #T)
(#x12401 . #T)
(#x12402 . #T)
(#x12403 . #T)
(#x12404 . #T)
(#x12405 . #T)
(#x12406 . #T)
(#x12407 . #T)
(#x12408 . #T)
(#x12409 . #T)
(#x1240A . #T)
(#x1240B . #T)
(#x1240C . #T)
(#x1240D . #T)
(#x1240E . #T)
(#x1240F . #T)
(#x12410 . #T)
(#x12411 . #T)
(#x12412 . #T)
(#x12413 . #T)
(#x12414 . #T)
(#x12415 . #T)
(#x12416 . #T)
(#x12417 . #T)
(#x12418 . #T)
(#x12419 . #T)
(#x1241A . #T)
(#x1241B . #T)
(#x1241C . #T)
(#x1241D . #T)
(#x1241E . #T)
(#x1241F . #T)
(#x12420 . #T)
(#x12421 . #T)
(#x12422 . #T)
(#x12423 . #T)
(#x12424 . #T)
(#x12425 . #T)
(#x12426 . #T)
(#x12427 . #T)
(#x12428 . #T)
(#x12429 . #T)
(#x1242A . #T)
(#x1242B . #T)
(#x1242C . #T)
(#x1242D . #T)
(#x1242E . #T)
(#x1242F . #T)
(#x12430 . #T)
(#x12431 . #T)
(#x12432 . #T)
(#x12433 . #T)
(#x12434 . #T)
(#x12435 . #T)
(#x12436 . #T)
(#x12437 . #T)
(#x12438 . #T)
(#x12439 . #T)
(#x1243A . #T)
(#x1243B . #T)
(#x1243C . #T)
(#x1243D . #T)
(#x1243E . #T)
(#x1243F . #T)
(#x12440 . #T)
(#x12441 . #T)
(#x12442 . #T)
(#x12443 . #T)
(#x12444 . #T)
(#x12445 . #T)
(#x12446 . #T)
(#x12447 . #T)
(#x12448 . #T)
(#x12449 . #T)
(#x1244A . #T)
(#x1244B . #T)
(#x1244C . #T)
(#x1244D . #T)
(#x1244E . #T)
(#x1244F . #T)
(#x12450 . #T)
(#x12451 . #T)
(#x12452 . #T)
(#x12453 . #T)
(#x12454 . #T)
(#x12455 . #T)
(#x12456 . #T)
(#x12457 . #T)
(#x12458 . #T)
(#x12459 . #T)
(#x1245A . #T)
(#x1245B . #T)
(#x1245C . #T)
(#x1245D . #T)
(#x1245E . #T)
(#x1245F . #T)
(#x12460 . #T)
(#x12461 . #T)
(#x12462 . #T)
(#x12463 . #T)
(#x12464 . #T)
(#x12465 . #T)
(#x12466 . #T)
(#x12467 . #T)
(#x12468 . #T)
(#x12469 . #T)
(#x1246A . #T)
(#x1246B . #T)
(#x1246C . #T)
(#x1246D . #T)
(#x1246E . #T)
(#x16A60 . 0)
(#x16A61 . 1)
(#x16A62 . 2)
(#x16A63 . 3)
(#x16A64 . 4)
(#x16A65 . 5)
(#x16A66 . 6)
(#x16A67 . 7)
(#x16A68 . 8)
(#x16A69 . 9)
(#x16AC0 . 0)
(#x16AC1 . 1)
(#x16AC2 . 2)
(#x16AC3 . 3)
(#x16AC4 . 4)
(#x16AC5 . 5)
(#x16AC6 . 6)
(#x16AC7 . 7)
(#x16AC8 . 8)
(#x16AC9 . 9)
(#x16B50 . 0)
(#x16B51 . 1)
(#x16B52 . 2)
(#x16B53 . 3)
(#x16B54 . 4)
(#x16B55 . 5)
(#x16B56 . 6)
(#x16B57 . 7)
(#x16B58 . 8)
(#x16B59 . 9)
(#x16B5B . #T)
(#x16B5C . #T)
(#x16B5D . #T)
(#x16B5E . #T)
(#x16B5F . #T)
(#x16B60 . #T)
(#x16B61 . #T)
(#x16E80 . 0)
(#x16E81 . 1)
(#x16E82 . 2)
(#x16E83 . 3)
(#x16E84 . 4)
(#x16E85 . 5)
(#x16E86 . 6)
(#x16E87 . 7)
(#x16E88 . 8)
(#x16E89 . 9)
(#x16E8A . #T)
(#x16E8B . #T)
(#x16E8C . #T)
(#x16E8D . #T)
(#x16E8E . #T)
(#x16E8F . #T)
(#x16E90 . #T)
(#x16E91 . #T)
(#x16E92 . #T)
(#x16E93 . #T)
(#x16E94 . 1)
(#x16E95 . 2)
(#x16E96 . 3)
(#x1D2E0 . #T)
(#x1D2E1 . #T)
(#x1D2E2 . #T)
(#x1D2E3 . #T)
(#x1D2E4 . #T)
(#x1D2E5 . #T)
(#x1D2E6 . #T)
(#x1D2E7 . #T)
(#x1D2E8 . #T)
(#x1D2E9 . #T)
(#x1D2EA . #T)
(#x1D2EB . #T)
(#x1D2EC . #T)
(#x1D2ED . #T)
(#x1D2EE . #T)
(#x1D2EF . #T)
(#x1D2F0 . #T)
(#x1D2F1 . #T)
(#x1D2F2 . #T)
(#x1D2F3 . #T)
(#x1D360 . 1)
(#x1D361 . 2)
(#x1D362 . 3)
(#x1D363 . 4)
(#x1D364 . 5)
(#x1D365 . 6)
(#x1D366 . 7)
(#x1D367 . 8)
(#x1D368 . 9)
(#x1D369 . 1)
(#x1D36A . 2)
(#x1D36B . 3)
(#x1D36C . 4)
(#x1D36D . 5)
(#x1D36E . 6)
(#x1D36F . 7)
(#x1D370 . 8)
(#x1D371 . 9)
(#x1D372 . #T)
(#x1D373 . #T)
(#x1D374 . #T)
(#x1D375 . #T)
(#x1D376 . #T)
(#x1D377 . #T)
(#x1D378 . #T)
(#x1D7CE . 0)
(#x1D7CF . 1)
(#x1D7D0 . 2)
(#x1D7D1 . 3)
(#x1D7D2 . 4)
(#x1D7D3 . 5)
(#x1D7D4 . 6)
(#x1D7D5 . 7)
(#x1D7D6 . 8)
(#x1D7D7 . 9)
(#x1D7D8 . 0)
(#x1D7D9 . 1)
(#x1D7DA . 2)
(#x1D7DB . 3)
(#x1D7DC . 4)
(#x1D7DD . 5)
(#x1D7DE . 6)
(#x1D7DF . 7)
(#x1D7E0 . 8)
(#x1D7E1 . 9)
(#x1D7E2 . 0)
(#x1D7E3 . 1)
(#x1D7E4 . 2)
(#x1D7E5 . 3)
(#x1D7E6 . 4)
(#x1D7E7 . 5)
(#x1D7E8 . 6)
(#x1D7E9 . 7)
(#x1D7EA . 8)
(#x1D7EB . 9)
(#x1D7EC . 0)
(#x1D7ED . 1)
(#x1D7EE . 2)
(#x1D7EF . 3)
(#x1D7F0 . 4)
(#x1D7F1 . 5)
(#x1D7F2 . 6)
(#x1D7F3 . 7)
(#x1D7F4 . 8)
(#x1D7F5 . 9)
(#x1D7F6 . 0)
(#x1D7F7 . 1)
(#x1D7F8 . 2)
(#x1D7F9 . 3)
(#x1D7FA . 4)
(#x1D7FB . 5)
(#x1D7FC . 6)
(#x1D7FD . 7)
(#x1D7FE . 8)
(#x1D7FF . 9)
(#x1E140 . 0)
(#x1E141 . 1)
(#x1E142 . 2)
(#x1E143 . 3)
(#x1E144 . 4)
(#x1E145 . 5)
(#x1E146 . 6)
(#x1E147 . 7)
(#x1E148 . 8)
(#x1E149 . 9)
(#x1E2F0 . 0)
(#x1E2F1 . 1)
(#x1E2F2 . 2)
(#x1E2F3 . 3)
(#x1E2F4 . 4)
(#x1E2F5 . 5)
(#x1E2F6 . 6)
(#x1E2F7 . 7)
(#x1E2F8 . 8)
(#x1E2F9 . 9)
(#x1E8C7 . 1)
(#x1E8C8 . 2)
(#x1E8C9 . 3)
(#x1E8CA . 4)
(#x1E8CB . 5)
(#x1E8CC . 6)
(#x1E8CD . 7)
(#x1E8CE . 8)
(#x1E8CF . 9)
(#x1E950 . 0)
(#x1E951 . 1)
(#x1E952 . 2)
(#x1E953 . 3)
(#x1E954 . 4)
(#x1E955 . 5)
(#x1E956 . 6)
(#x1E957 . 7)
(#x1E958 . 8)
(#x1E959 . 9)
(#x1EC71 . #T)
(#x1EC72 . #T)
(#x1EC73 . #T)
(#x1EC74 . #T)
(#x1EC75 . #T)
(#x1EC76 . #T)
(#x1EC77 . #T)
(#x1EC78 . #T)
(#x1EC79 . #T)
(#x1EC7A . #T)
(#x1EC7B . #T)
(#x1EC7C . #T)
(#x1EC7D . #T)
(#x1EC7E . #T)
(#x1EC7F . #T)
(#x1EC80 . #T)
(#x1EC81 . #T)
(#x1EC82 . #T)
(#x1EC83 . #T)
(#x1EC84 . #T)
(#x1EC85 . #T)
(#x1EC86 . #T)
(#x1EC87 . #T)
(#x1EC88 . #T)
(#x1EC89 . #T)
(#x1EC8A . #T)
(#x1EC8B . #T)
(#x1EC8C . #T)
(#x1EC8D . #T)
(#x1EC8E . #T)
(#x1EC8F . #T)
(#x1EC90 . #T)
(#x1EC91 . #T)
(#x1EC92 . #T)
(#x1EC93 . #T)
(#x1EC94 . #T)
(#x1EC95 . #T)
(#x1EC96 . #T)
(#x1EC97 . #T)
(#x1EC98 . #T)
(#x1EC99 . #T)
(#x1EC9A . #T)
(#x1EC9B . #T)
(#x1EC9C . #T)
(#x1EC9D . #T)
(#x1EC9E . #T)
(#x1EC9F . #T)
(#x1ECA0 . #T)
(#x1ECA1 . #T)
(#x1ECA2 . #T)
(#x1ECA3 . #T)
(#x1ECA4 . #T)
(#x1ECA5 . #T)
(#x1ECA6 . #T)
(#x1ECA7 . #T)
(#x1ECA8 . #T)
(#x1ECA9 . #T)
(#x1ECAA . #T)
(#x1ECAB . #T)
(#x1ECAD . #T)
(#x1ECAE . #T)
(#x1ECAF . #T)
(#x1ECB1 . #T)
(#x1ECB2 . #T)
(#x1ECB3 . #T)
(#x1ECB4 . #T)
(#x1ED01 . #T)
(#x1ED02 . #T)
(#x1ED03 . #T)
(#x1ED04 . #T)
(#x1ED05 . #T)
(#x1ED06 . #T)
(#x1ED07 . #T)
(#x1ED08 . #T)
(#x1ED09 . #T)
(#x1ED0A . #T)
(#x1ED0B . #T)
(#x1ED0C . #T)
(#x1ED0D . #T)
(#x1ED0E . #T)
(#x1ED0F . #T)
(#x1ED10 . #T)
(#x1ED11 . #T)
(#x1ED12 . #T)
(#x1ED13 . #T)
(#x1ED14 . #T)
(#x1ED15 . #T)
(#x1ED16 . #T)
(#x1ED17 . #T)
(#x1ED18 . #T)
(#x1ED19 . #T)
(#x1ED1A . #T)
(#x1ED1B . #T)
(#x1ED1C . #T)
(#x1ED1D . #T)
(#x1ED1E . #T)
(#x1ED1F . #T)
(#x1ED20 . #T)
(#x1ED21 . #T)
(#x1ED22 . #T)
(#x1ED23 . #T)
(#x1ED24 . #T)
(#x1ED25 . #T)
(#x1ED26 . #T)
(#x1ED27 . #T)
(#x1ED28 . #T)
(#x1ED29 . #T)
(#x1ED2A . #T)
(#x1ED2B . #T)
(#x1ED2C . #T)
(#x1ED2D . #T)
(#x1ED2F . #T)
(#x1ED30 . #T)
(#x1ED31 . #T)
(#x1ED32 . #T)
(#x1ED33 . #T)
(#x1ED34 . #T)
(#x1ED35 . #T)
(#x1ED36 . #T)
(#x1ED37 . #T)
(#x1ED38 . #T)
(#x1ED39 . #T)
(#x1ED3A . #T)
(#x1ED3B . #T)
(#x1ED3C . #T)
(#x1ED3D . #T)
(#x1F100 . 0)
(#x1F101 . 0)
(#x1F102 . 1)
(#x1F103 . 2)
(#x1F104 . 3)
(#x1F105 . 4)
(#x1F106 . 5)
(#x1F107 . 6)
(#x1F108 . 7)
(#x1F109 . 8)
(#x1F10A . 9)
(#x1F10B . 0)
(#x1F10C . 0)
(#x1FBF0 . 0)
(#x1FBF1 . 1)
(#x1FBF2 . 2)
(#x1FBF3 . 3)
(#x1FBF4 . 4)
(#x1FBF5 . 5)
(#x1FBF6 . 6)
(#x1FBF7 . 7)
(#x1FBF8 . 8)
(#x1FBF9 . 9)
))
