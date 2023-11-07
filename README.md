# build_ffmpeg
build ffmpeg scripts and other third party libary.

# tips
- we use ffmpeg release/4.4 base branch for hevc, new feature in feature/support_hevc_base_rc4.4 
- new ffmpeg has support hevc in release/6.1, details see: [FFmpeg直播能力更新计划与新版本发布](https://mp.weixin.qq.com/s?__biz=MzU1NTEzOTM5Mw==&mid=2247544719&idx=1&sn=adab4dc72c288f2ff0c3030764e7dfa3&chksm=fbda87a1ccad0eb79c80763bf29be02c34102b4189a42ad557372df533aa5fa4c9821b2177f1&mpshare=1&srcid=1102iQzHf9me75JY4dALi5X6&sharer_shareinfo=9faed9f1f48a58a37c43537bab0e9510&sharer_shareinfo_first=9faed9f1f48a58a37c43537bab0e9510&from=timeline&scene=2&subscene=1&sessionid=1698887365&clicktime=1698887853&enterid=1698887853&ascene=2&fasttmpl_type=0&fasttmpl_fullversion=6925598-zh_CN-zip&fasttmpl_flag=0&realreporttime=1698887853943&devicetype=android-33&version=28002964&nettype=ctnet&abtest_cookie=AAACAA%3D%3D&lang=zh_CN&countrycode=CN&exportkey=n_ChQIAhIQGL5QSzxMcFWy8pBXw%2Bc8JxLlAQIE97dBBAEAAAAAAPTOD6NHGIcAAAAOpnltbLcz9gKNyK89dVj0WZuFc1kHzdpi%2Fas2jCFJLTrzp62ZkreFunkQCIXXgm2lEJZqO4juMhWs%2FxEUmFHgD57suLU3GcAMR488T0ib36e3XbG%2BJQDn4MrbdYhDCaRr8gPcGFrgXx4i3Fj4SCtW%2Fv4jW5gUM4jKB24aEKShaQcaaeIcPtXe9%2FDAjF4c7HpQ12kjNNt7%2FiBt9xje2LEDxdXqWko1fGZlIwG%2FZVwNC%2Fzo%2B5sZJ4VrXD%2FUnY3EN7%2F1eezJFF%2FRQtKtRxHEm6U%3D&pass_ticket=KDVXQCF8NKcODKlXkzYG7WJH9WVwvTWMlIItWWWoty%2BUJuQNC3XV7KDzjAIjRoPC&wx_header=3)

# steps
- step1: if need x265, download source code from https://www.x265.org/downloads/ by yourself. then save x265_v3.3.tar.gz to 3rd dir.
- step2: run scripts/build_ffmpeg.sh and get ffmpeg release in install dir.
