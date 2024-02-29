-- prevalence for each sdk and taxonomy for each app category (excel tabs named: table 2 and table 4 and Fig 7 App Category Prevalence)
SELECT c.Category, t.SDK AS SDK_Name, t.Category AS SDK_Category, COUNT(DISTINCT a.APKName) AS Prevalence
FROM apk_classes_consolidated a
    JOIN categories c ON a.APKName = c.APKName
    JOIN sdks t ON a.Classpath LIKE t.Classpath || '%'
GROUP BY c.Category, t.SDK, t.Category
ORDER BY c.Category, t.SDK, Prevalence DESC;

-- prevalence for each sdk and taxonomy (excel tab name: table 3)

SELECT t.SDK, t.Category, COUNT(DISTINCT a.APKName) AS Prevalence
FROM sdks t
    JOIN apk_classes_consolidated a ON a.Classpath LIKE t.Classpath || '%'
GROUP BY t.SDK, t.Category
ORDER BY t.SDK, t.Category, Prevalence DESC;

-- number apps using the privacy infringing namespaces per download bracket (excel tab name: table 5)
SELECT count( distinct APKName) AS n_APKs, ServiceName, max_nb_downloads
FROM apk_classes_consolidated acc
JOIN download_list dl ON acc.APKName = dl.pkg_name
JOIN privacy_infringing pi ON acc.ClassPath LIKE pi.Namespace || '%'
GROUP BY ServiceName, max_nb_downloads;


-- privacy infringing namespace CSV, name it as temp.csv:

-- vision,com.google.android.gms.vision.
-- inappmessaging,com.google.firebase.inappmessaging.
-- auth,com.google.firebase.auth.
-- wallet,com.google.android.gms.wallet.
-- fido,com.google.android.gms.fido.
-- analytics,com.google.firebase.analytics.
-- measurement,com.google.android.gms.measurement.

CREATE TABLE privacy_infringing AS SELECT * FROM read_csv('temp.csv', AUTO_DETECT=TRUE);
ALTER TABLE privacy_infringing RENAME column0 TO ServiceName;
ALTER TABLE privacy_infringing RENAME column1 TO Namespace;

-- number of apks using the privacy infringing namespaces
SELECT count( distinct APKName) AS n_APKs, ServiceName
FROM apk_classes_consolidated acc
JOIN download_list dl ON acc.APKName = dl.pkg_name
JOIN privacy_infringing pi ON acc.ClassPath LIKE pi.Namespace || '%'
GROUP BY ServiceName;

-- number of apks per download bracket using the privacy infringing namespaces
SELECT count( distinct APKName) AS n_APKs, ServiceName, max_nb_downloads
FROM apk_classes_consolidated acc
JOIN download_list dl ON acc.APKName = dl.pkg_name
JOIN privacy_infringing pi ON acc.ClassPath LIKE pi.Namespace || '%'
GROUP BY ServiceName, max_nb_downloads;

-- ----- table 1 in the paper
-- This is the large query with the manual exclusion from the method section, which also includes the values in table 1
-- in the comment per namespace, you can see the top 9 i.e. 559678 corresponds to one of the values in table 1.
-- In table 1, we only included the top SDKs from the outlier analysis.
-- The rest of the query includes the various non SDK with services that were excluded one by one.
SELECT *
FROM (SELECT ClassPath, SUM(cnt) AS agg
        FROM sdk_count
        GROUP BY ClassPath
        ORDER BY agg DESC) stitched
WHERE stitched.agg > 2000


    AND stitched.ClassPath NOT LIKE 'com.google.android.gms.%' -- 559678 - admob
    AND stitched.ClassPath NOT LIKE 'com.google.firebase.%' -- 389619 - firebase
    AND stitched.ClassPath NOT LIKE 'com.google.ads.%' -- 378849 - old google ads? https://developers.google.com/ad-manager/mobile-ads-sdk/android/custom-events/setup
    AND stitched.ClassPath NOT LIKE 'com.facebook.ads.%' -- 151667 - facebook
    AND stitched.ClassPath NOT LIKE 'com.facebook.%' -- other non ad stuff keeps appearing 100k
    AND stitched.ClassPath NOT LIKE 'com.google.android.ads.%' -- 142818 - ?
    AND stitched.ClassPath NOT LIKE 'com.unity3d.ads.%' -- 114178 - unity game ads
    AND stitched.ClassPath NOT LIKE 'com.unity3d.services.%' -- 109546 - unity game ads
    AND stitched.ClassPath NOT LIKE 'com.unity3d.%' -- other non ad stuff keeps appearing 100k
    AND stitched.ClassPath NOT LIKE 'com.applovin.%' -- 89703 - applovin
    AND stitched.ClassPath NOT LIKE 'com.ironsource.%' -- 63555 - ironsource
    AND stitched.ClassPath NOT LIKE 'com.google.unity.ads.%' -- 51910 -
    AND stitched.ClassPath NOT LIKE 'com.unity.purchasing.%' -- 46010 -
    AND stitched.ClassPath NOT LIKE 'com.adcolony.%' -- 45347 -
    AND stitched.ClassPath NOT LIKE 'com.appsflyer.%' -- 43138 -
    AND stitched.ClassPath NOT LIKE 'com.vungle.%' -- 40482 -
    AND stitched.ClassPath NOT LIKE 'com.bytedance.sdk.%' -- 35408 -
    AND stitched.ClassPath NOT LIKE 'com.bytedance.%' -- other non ad stuff keeps appearing 30k
    AND stitched.ClassPath NOT LIKE 'com.apm.insight.%' -- 30988 - https://www.appdynamics.com/supported-technologies/android
    AND stitched.ClassPath NOT LIKE 'com.inmobi.%' -- 29283 - https://www.inmobi.com/
    AND stitched.ClassPath NOT LIKE 'com.startapp.%' -- 29755 - https://www.start.io/
    AND stitched.ClassPath NOT LIKE 'com.mbridge.msdk.%' -- 27392 - https://www.mintegral.com/en
    AND stitched.ClassPath NOT LIKE 'firebase.com.%' -- 26290
    AND stitched.ClassPath NOT LIKE 'com.adjust.sdk.%' -- 24919 - https://www.adjust.com/
    AND stitched.ClassPath NOT LIKE 'com.squareup.%' -- 24348 - square payment
    AND stitched.ClassPath NOT LIKE 'com.fyber.%' -- 23127 - https://www.digitalturbine.com/
    AND stitched.ClassPath NOT LIKE 'com.flurry.%' -- 21452 - https://www.flurry.com/
    AND stitched.ClassPath NOT LIKE 'com.safedk.%' -- 21254 - https://www.applovin.com/blog/applovin-acquires-safedk/
    AND stitched.ClassPath NOT LIKE 'com.tapjoy.%' -- 21058 - https://www.is.com/tapjoy/
    AND stitched.ClassPath NOT LIKE 'com.chartboost.%' -- 20925 - https://www.chartboost.com/
    AND stitched.ClassPath NOT LIKE 'io.sentry.%' -- 20020 - https://sentry.io/welcome/
    AND stitched.ClassPath NOT LIKE 'com.crashlytics.%' -- 18326 - old firebase classpath pre-2018?
    AND stitched.ClassPath NOT LIKE 'io.fabric.sdk.%' -- 17273 - https://firebase.google.com/docs/reference/android/io/fabric/sdk/android/fabric/package-summary
    AND stitched.ClassPath NOT LIKE 'com.digitalturbine.%' -- 14793 - https://www.digitalturbine.com/
    AND stitched.ClassPath NOT LIKE 'com.google.firestore.%' -- 13377 -
    AND stitched.ClassPath NOT LIKE 'com.amazon.device.ads.%' -- 12476 - https://developer.amazon.com/apps-and-games/mobile-ads
    AND stitched.ClassPath NOT LIKE 'com.amazonaws.%' -- other non ad stuff 9k
    AND stitched.ClassPath NOT LIKE 'com.microsoft.appcenter.%' -- 12435 - https://appcenter.ms/
    AND stitched.ClassPath NOT LIKE 'com.mopub.%' -- 12435 - https://www.applovin.com/max/
    AND stitched.ClassPath NOT LIKE 'com.gameanalytics.sdk.%' -- 11043 - https://gameanalytics.com/
    AND stitched.ClassPath NOT LIKE 'com.smaato.sdk.%' -- 9083 - https://www.smaato.com/
    AND stitched.ClassPath NOT LIKE 'com.my.tracker.%' -- 8547 - https://tracker.my.com/
    AND stitched.ClassPath NOT LIKE 'com.google.android.vending.%' -- 8442
    AND stitched.ClassPath NOT LIKE 'com.pgl.ssdk.%' -- 8353 - https://www.phonepe.com/
    AND stitched.ClassPath NOT LIKE 'com.amazon.device.iap.%' -- 7677 - https://developer.amazon.com/docs/in-app-purchasing/iap-implement-iap.html
    AND stitched.ClassPath NOT LIKE 'com.explorestack.%' -- 7572 - https://appodealstack.com/
    AND stitched.ClassPath NOT LIKE 'com.appnext.%' -- 7372 - https://developers.appnext.com/
    AND stitched.ClassPath NOT LIKE 'com.anjlab.%' -- 7167 - https://anjlab.com/en/
    AND stitched.ClassPath NOT LIKE 'com.stripe.%' -- 7106 - https://stripe.com/docs/libraries/android?locale=en-GB
    AND stitched.ClassPath NOT LIKE 'com.twitter.%' -- 7104 - https://developer.twitter.com/en/docs/twitter-api/tools-and-libraries/sdks/overview
    AND stitched.ClassPath NOT LIKE 'com.moat.analytics.%' -- 6885 - https://www.oracle.com/advertising/measurement/
    AND stitched.ClassPath NOT LIKE 'developers.mobile.abt.%' -- 6659 - old firebase format for A/B testing?
    AND stitched.ClassPath NOT LIKE 'io.opencensus.%' -- 6545 - open source for many backends but including https://opencensus.io/
    AND stitched.ClassPath NOT LIKE 'io.branch.%' -- 6472 - https://www.branch.io/
    AND stitched.ClassPath NOT LIKE 'io.bidmachine.%' -- 6414 - https://docs.bidmachine.io/docs/getting-started
    AND stitched.ClassPath NOT LIKE 'com.amplitude.api.%' -- 6333 - https://www.docs.developers.amplitude.com/#
    AND stitched.ClassPath NOT LIKE 'com.microsoft.codepush.%' -- 6216 - https://learn.microsoft.com/en-us/appcenter/distribution/codepush/
    AND stitched.ClassPath NOT LIKE 'expo.modules.%' -- 6178 - https://docs.expo.dev/bare/installing-expo-modules/
    AND stitched.ClassPath NOT LIKE 'com.razorpay.%' -- 6161 - https://razorpay.com/docs/payments/payment-gateway/android-integration/standard/
    AND stitched.ClassPath NOT LIKE 'com.amazon.aps.shared.analytics.%' -- 5861 - https://docs.aws.amazon.com/pinpoint/latest/developerguide/event-streams-data-app.html
    AND stitched.ClassPath NOT LIKE 'com.criteo.%' -- 5813 - https://www.criteo.com/
    AND stitched.ClassPath NOT LIKE 'com.appodeal.%' -- 5813 - https://appodeal.com/
    AND stitched.ClassPath NOT LIKE 'com.amazon.aps.%' -- 5583 - https://aps.amazon.com/aps/solutions-for-mobile-app-developers/
    AND stitched.ClassPath NOT LIKE 'com.umeng.analytics.%' -- 5400 - https://www.umeng.com/analytics
    AND stitched.ClassPath NOT LIKE 'com.google.appinventor.%' -- 5362 - https://appinventor.mit.edu/
    AND stitched.ClassPath NOT LIKE 'com.truenet.%' -- 5359 - cant find home page
    AND stitched.ClassPath NOT LIKE 'io.card.payment.%' -- 5319 - https://card-io.github.io/


    -- not Ad SDKs
    AND stitched.ClassPath != 'AndroidManifest.xml'
    AND stitched.ClassPath != 'classes.dex'
    AND stitched.ClassPath != 'classes2.dex'
    AND stitched.ClassPath != 'classes3.dex'
    AND stitched.ClassPath != 'classes4.dex'
    AND stitched.ClassPath != 'classes5.dex'
    AND stitched.ClassPath != 'classes6.dex'
    AND stitched.ClassPath != 'classes7.dex'
    AND stitched.ClassPath != 'classes8.dex'
    AND stitched.ClassPath != 'classes9.dex'
    AND NOT length(stitched.ClassPath) <= 5

    AND stitched.ClassPath NOT LIKE '%$%'
    AND stitched.ClassPath NOT LIKE '%.xml'
    AND stitched.ClassPath NOT LIKE '%.a'
    AND stitched.ClassPath NOT LIKE '%.b'
    AND stitched.ClassPath NOT LIKE '%.c'
    AND stitched.ClassPath NOT LIKE '%.d'
    AND stitched.ClassPath NOT LIKE '%.e'
    AND stitched.ClassPath NOT LIKE '%.f'
    AND stitched.ClassPath NOT LIKE '%.g'
    AND stitched.ClassPath NOT LIKE '%.h'
    AND stitched.ClassPath NOT LIKE '%.i'
    AND stitched.ClassPath NOT LIKE '%.j'
    AND stitched.ClassPath NOT LIKE '%.k'
    AND stitched.ClassPath NOT LIKE '%.l'
    AND stitched.ClassPath NOT LIKE '%.m'
    AND stitched.ClassPath NOT LIKE '%.n'
    AND stitched.ClassPath NOT LIKE '%.o'
    AND stitched.ClassPath NOT LIKE '%.p'
    AND stitched.ClassPath NOT LIKE '%.q'
    AND stitched.ClassPath NOT LIKE '%.r'
    AND stitched.ClassPath NOT LIKE '%.s'
    AND stitched.ClassPath NOT LIKE '%.t'
    AND stitched.ClassPath NOT LIKE '%.u'
    AND stitched.ClassPath NOT LIKE '%.v'
    AND stitched.ClassPath NOT LIKE '%.w'
    AND stitched.ClassPath NOT LIKE '%.x'
    AND stitched.ClassPath NOT LIKE '%.y'
    AND stitched.ClassPath NOT LIKE '%.z'

    AND stitched.ClassPath NOT LIKE 'kotlin.%'
    AND stitched.ClassPath NOT LIKE 'kotlinx.%'
    AND stitched.ClassPath NOT LIKE 'android.%'
    AND stitched.ClassPath NOT LIKE 'androidx.%'
    AND stitched.ClassPath NOT LIKE 'res/%'
    AND stitched.ClassPath NOT LIKE 'com.google.android.material.%'
    AND stitched.ClassPath NOT LIKE 'okhttp3.%'
    AND stitched.ClassPath NOT LIKE 'com.google.gson.%'
    AND stitched.ClassPath NOT LIKE 'org.intellij.%'
    AND stitched.ClassPath NOT LIKE 'okio.%'
    AND stitched.ClassPath NOT LIKE 'javax.%'
    AND stitched.ClassPath NOT LIKE 'com.google.android.datatransport.%'
    AND stitched.ClassPath NOT LIKE 'com.google.common.%'
    AND stitched.ClassPath NOT LIKE 'org.jetbrains.%'
    AND stitched.ClassPath NOT LIKE 'com.bumptech.glide.%'
    AND stitched.ClassPath NOT LIKE 'com.android.installreferrer.%'
    AND stitched.ClassPath NOT LIKE 'assets/%'
    AND stitched.ClassPath NOT LIKE 'com.android.billingclient.%'
    AND stitched.ClassPath NOT LIKE 'com.google.android.ump.%'
    AND stitched.ClassPath NOT LIKE 'com.facebook.internal.%'
    AND stitched.ClassPath NOT LIKE 'com.facebook.core.%'
    AND stitched.ClassPath NOT LIKE 'com.google.android.play.%'
    AND stitched.ClassPath NOT LIKE 'com.google.zxing.%'
    AND stitched.ClassPath NOT LIKE 'com.google.errorprone.%'
    AND stitched.ClassPath NOT LIKE 'com.squareup.picasso.%'
    AND stitched.ClassPath NOT LIKE 'com.google.android.finsky.%'
    AND stitched.ClassPath NOT LIKE 'retrofit2.%'
    AND stitched.ClassPath NOT LIKE 'org.fmod.%'
    AND stitched.ClassPath NOT LIKE 'bitter.%'
    AND stitched.ClassPath NOT LIKE 'com.google.android.exoplayer2.%'
    AND stitched.ClassPath NOT LIKE 'org.chromium.support_lib_boundary.%'
    AND stitched.ClassPath NOT LIKE 'bolts.%'
    AND stitched.ClassPath NOT LIKE 'com.airbnb.lottie.%'
    AND stitched.ClassPath NOT LIKE 'com.google.thirdparty.%'
    AND stitched.ClassPath NOT LIKE 'com.google.androidgamesdk.%'
    AND stitched.ClassPath NOT LIKE 'com.google.auto.%'
    AND stitched.ClassPath NOT LIKE 'com.android.volley.%'
    AND stitched.ClassPath NOT LIKE 'com.onesignal.%' -- push services
    AND stitched.ClassPath NOT LIKE 'dagger.%'
    AND stitched.ClassPath NOT LIKE 'io.reactivex.%'
    AND stitched.ClassPath NOT LIKE 'com.google.protobuf.%'
    AND stitched.ClassPath NOT LIKE 'org.reactivestreams.%'
    AND stitched.ClassPath NOT LIKE 'com.google.j2objc.%'
    AND stitched.ClassPath NOT LIKE 'org.greenrobot.eventbus.%' --
    AND stitched.ClassPath NOT LIKE 'de.hdodenhof.%' --
    AND stitched.ClassPath NOT LIKE 'com.android.vending.%' --
    AND stitched.ClassPath NOT LIKE 'com.google.android.flexbox.%' --
    AND stitched.ClassPath NOT LIKE 'io.flutter.%' --
    AND stitched.ClassPath NOT LIKE 'butterknife.%' --
    AND stitched.ClassPath NOT LIKE 'org.jsoup.%' --
    AND stitched.ClassPath NOT LIKE 'com.bytedance.applog.%'
    AND stitched.ClassPath NOT LIKE 'com.bykv.vk.openvk.%'
    AND stitched.ClassPath NOT LIKE 'com.google.api.%'
    AND stitched.ClassPath NOT LIKE 'com.google.rpc.%'
    AND stitched.ClassPath NOT LIKE 'com.google.type.%'
    AND stitched.ClassPath NOT LIKE 'com.google.logging.%'
    AND stitched.ClassPath NOT LIKE 'com.google.longrunning.%'
    AND stitched.ClassPath NOT LIKE 'com.google.cloud.%'
    AND stitched.ClassPath NOT LIKE 'org.codehaus.mojo.%'
    AND stitched.ClassPath NOT LIKE 'com.google.geo.%'
    AND stitched.ClassPath NOT LIKE 'org.apache.%'
    AND stitched.ClassPath NOT LIKE 'me.leolin.shortcutbadger.%'
    AND stitched.ClassPath NOT LIKE 'org.slf4j.%'
    AND stitched.ClassPath NOT LIKE 'io.grpc.%'
    AND stitched.ClassPath NOT LIKE 'com.fasterxml.%'
    AND stitched.ClassPath NOT LIKE 'com.yalantis.%'
    AND stitched.ClassPath NOT LIKE 'com.swmansion.%'
    AND stitched.ClassPath NOT LIKE 'com.google.maps.%'
    AND stitched.ClassPath NOT LIKE 'org.checkerframework.%'
    AND stitched.ClassPath NOT LIKE 'com.nineoldandroids.%'
    AND stitched.ClassPath NOT LIKE 'com.github.chrisbanes.%'
    AND stitched.ClassPath NOT LIKE 'pl.droidsonroids.%'
    AND stitched.ClassPath NOT LIKE 'com.reactnativecommunity.%'
    AND stitched.ClassPath NOT LIKE 'com.yandex.%'
    AND stitched.ClassPath NOT LIKE 'com.intuit.%'
    AND stitched.ClassPath NOT LIKE 'com.th3rdwave.%'
    AND stitched.ClassPath NOT LIKE 'com.shockwave.pdfium.%'
    AND stitched.ClassPath NOT LIKE 'me.zhanghai.android.%'
    AND stitched.ClassPath NOT LIKE 'com.makeramen.%'
    AND stitched.ClassPath NOT LIKE 'com.horcrux.%'
    AND stitched.ClassPath NOT LIKE 'timber.%'
    AND stitched.ClassPath NOT LIKE 'com.karumi.%'
    AND stitched.ClassPath NOT LIKE 'com.theartofdev.%'
    AND stitched.ClassPath NOT LIKE 'ms.bd.o.%' -- ???
    AND stitched.ClassPath NOT LIKE 'com.google.android.youtube.%'
    AND stitched.ClassPath NOT LIKE 'com.github.mikephil.%'
    AND stitched.ClassPath NOT LIKE 'com.github.barteksc.%'
    AND stitched.ClassPath NOT LIKE 'org.joda.%'
    AND stitched.ClassPath NOT LIKE 'com.github.ybq.%'
    AND stitched.ClassPath NOT LIKE 'com.learnium.%'
    AND stitched.ClassPath NOT LIKE 'io.perfmark.%'
    AND stitched.ClassPath NOT LIKE 'com.google.mlkit.%'
    AND stitched.ClassPath NOT LIKE 'com.google.unity.%'
    AND stitched.ClassPath NOT LIKE 'com.wang.avi.%'
    AND stitched.ClassPath NOT LIKE 'coil.target.%'
    AND stitched.ClassPath NOT LIKE 'io.invertase.%'
    AND stitched.ClassPath NOT LIKE 'com.google.crypto.%'
    AND stitched.ClassPath NOT LIKE 'com.journeyapps.%'
    AND stitched.ClassPath NOT LIKE 'com.afollestad.%'
    AND stitched.ClassPath NOT LIKE 'com.unity.androidnotifications.%'
    AND stitched.ClassPath NOT LIKE 'com.oblador.%'
    AND stitched.ClassPath NOT LIKE 'dalvik.system.%'
    AND stitched.ClassPath NOT LIKE 'rx.exceptions.%'
    AND stitched.ClassPath NOT LIKE 'org.bouncycastle.%'
    AND stitched.ClassPath NOT LIKE 'com.pichillilorenzo.%'
    AND stitched.ClassPath NOT LIKE 'com.nostra13.%'
    AND stitched.ClassPath NOT LIKE 'com.BV.%'
    AND stitched.ClassPath NOT LIKE 'coil.util.%'
    AND stitched.ClassPath NOT LIKE 'org.reactnative.%'
    AND stitched.ClassPath NOT LIKE 'com.google.flatbuffers.%'
    AND stitched.ClassPath NOT LIKE 'org.chromium.%'
    AND stitched.ClassPath NOT LIKE 'com.google.android.recaptcha.%'
    AND stitched.ClassPath NOT LIKE 'com.yasirkula.%'
    AND stitched.ClassPath NOT LIKE 'cz.msebera.%'
    AND stitched.ClassPath NOT LIKE 'dev.fluttercommunity.%'
    AND stitched.ClassPath NOT LIKE 'com.loopj.%'
    AND stitched.ClassPath NOT LIKE 'org.cocos2dx.%'
    AND stitched.ClassPath NOT LIKE 'rx.schedulers.%'
    AND stitched.ClassPath NOT LIKE 'rx.internal.%'
    AND stitched.ClassPath NOT LIKE 'com.getkeepsafe.%'
    AND stitched.ClassPath NOT LIKE 'com.google.android.instantapps.%'
    AND stitched.ClassPath NOT LIKE 'coil.network.%'
    AND stitched.ClassPath NOT LIKE 'com.my.target.%'
    AND stitched.ClassPath NOT LIKE '_COROUTINE.%'
    AND stitched.ClassPath NOT LIKE 'rx.%'
    AND stitched.ClassPath NOT LIKE 'com.google.games.bridge.%'
    AND stitched.ClassPath NOT LIKE 'coil.request.%'
    AND stitched.ClassPath NOT LIKE 'com.google.internal.firebase.inappmessaging.%'
    AND stitched.ClassPath NOT LIKE 'com.nimbusds.%'
    AND stitched.ClassPath NOT LIKE 'com.viewpagerindicator.%'
    AND stitched.ClassPath NOT LIKE 'com.dexterous.%'
    AND stitched.ClassPath NOT LIKE 'pub.devrel.easypermissions.%'
    AND stitched.ClassPath NOT LIKE 'com.google.example.%'
    AND stitched.ClassPath NOT LIKE 'org.junit.%'
    AND stitched.ClassPath NOT LIKE 'com.google.android.libraries.%'
    AND stitched.ClassPath NOT LIKE 'org.webkit.%'
    AND stitched.ClassPath NOT LIKE 'com.github.clans.%'
    AND stitched.ClassPath NOT LIKE 'io.realm.%' -- db for mobile by mongodb
    AND stitched.ClassPath NOT LIKE 'org.koin.%'
    AND stitched.ClassPath NOT LIKE 'coil.memory.%'
    AND stitched.ClassPath NOT LIKE 'com.daimajia.%'
    AND stitched.ClassPath NOT LIKE 'com.dylanvann.%'
    AND stitched.ClassPath NOT LIKE 'net.jcip.%'
    AND stitched.ClassPath NOT LIKE 'com.viewpagerindicator.%'
    AND stitched.ClassPath NOT LIKE 'org.objectweb.%'
    AND stitched.ClassPath NOT LIKE 'org.devio.%'
    AND stitched.ClassPath NOT LIKE 'com.scottyab.%'
    AND stitched.ClassPath NOT LIKE 'io.michaelrocks.%'
    AND stitched.ClassPath NOT LIKE 'com.google.i18n.%'
    AND stitched.ClassPath NOT LIKE 'com.google.developers.%'
    AND stitched.ClassPath NOT LIKE 'me.relex.circleindicator.%'
    AND stitched.ClassPath NOT LIKE 'coil.size.%'
    AND stitched.ClassPath NOT LIKE 'coil.decode.%'
    AND stitched.ClassPath NOT LIKE 'com.zoontek.%'
    AND stitched.ClassPath NOT LIKE 'com.android.databinding.%'
    AND stitched.ClassPath NOT LIKE 'coil.RealImageLoader%'
    AND stitched.ClassPath NOT LIKE 'org.hamcrest.%'
    AND stitched.ClassPath NOT LIKE 'junit.%'
    AND stitched.ClassPath NOT LIKE 'org.threeten.%'
    AND stitched.ClassPath NOT LIKE 'com.rd.%'
    AND stitched.ClassPath NOT LIKE 'com.balysv.%'
    AND stitched.ClassPath NOT LIKE 'coil.decode.%'
    AND stitched.ClassPath NOT LIKE 'org.xmlpull.%'
    AND stitched.ClassPath NOT LIKE 'coil.fetch.%'
    AND stitched.ClassPath NOT LIKE 'cl.json.%'
    AND stitched.ClassPath NOT LIKE 'com.airbnb.android.react.lottie.%'
    AND stitched.ClassPath NOT LIKE 'coil.%'
    AND stitched.ClassPath NOT LIKE 'com.rnfs.%'
    AND stitched.ClassPath NOT LIKE 'com.jirbo.%'
    AND stitched.ClassPath NOT LIKE 'com.pnikosis.%'
    AND stitched.ClassPath NOT LIKE 'nl.xservices.%'
    AND stitched.ClassPath NOT LIKE 'com.caverock.%'
    AND stitched.ClassPath NOT LIKE 'com.pierfrancescosoffritti.%'
    AND stitched.ClassPath NOT LIKE 'net.sqlcipher.%'
    AND stitched.ClassPath NOT LIKE 'com.google.apphosting.datastore.%'
    AND stitched.ClassPath NOT LIKE 'com.imagepicker.%'
    AND stitched.ClassPath NOT LIKE 'org.simpleframework.xml.%'
    AND stitched.ClassPath NOT LIKE 'com.google.android.odml.%'
    AND stitched.ClassPath NOT LIKE 'com.reactcommunity.%'
    AND stitched.ClassPath NOT LIKE 'io.github.inflationx.%'
    AND stitched.ClassPath NOT LIKE 'uk.co.senab.%'
    AND stitched.ClassPath NOT LIKE 'org.spongycastle.%'
    AND stitched.ClassPath NOT LIKE 'net.butterflytv.%'
    AND stitched.ClassPath NOT LIKE 'com.futuremind.%'
    AND stitched.ClassPath NOT LIKE 'jp.wasabeef.%'
    AND stitched.ClassPath NOT LIKE 'jp.co.cyberagent.%'
    AND stitched.ClassPath NOT LIKE 'com.RNFetchBlob.%'
    AND stitched.ClassPath NOT LIKE 'org.webrtc.%'
    AND stitched.ClassPath NOT LIKE 'com.reactnativepagerview.%'
    AND stitched.ClassPath NOT LIKE 'com.davemorrissey.%'
    AND stitched.ClassPath NOT LIKE 'net.minidev.%'
    AND stitched.ClassPath NOT LIKE 'com.wdullaer.%'
    AND stitched.ClassPath NOT LIKE 'com.sothree.%'
    AND stitched.ClassPath NOT LIKE 'mono.%'
    AND stitched.ClassPath NOT LIKE 'org.json.%'
    AND stitched.ClassPath NOT LIKE 'com.xamarin.%'
    AND stitched.ClassPath NOT LIKE 'com.hbb20.%'
    AND stitched.ClassPath NOT LIKE 'com.alibaba.fastjson.%'
    AND stitched.ClassPath NOT LIKE 'com.dieam.reactnativepushnotification.%'
    AND stitched.ClassPath NOT LIKE 'com.tencent.mmkv.%'
    AND stitched.ClassPath NOT LIKE 'com.brentvatne.react.%'
    AND stitched.ClassPath NOT LIKE 'com.google.android.cameraview.%'
    AND stitched.ClassPath NOT LIKE 'com.airbnb.android.react.%'
    AND stitched.ClassPath NOT LIKE 'com.chad.%'
    AND stitched.ClassPath NOT LIKE 'io.presage.%'
    AND stitched.ClassPath NOT LIKE 'com.ionicframework.%'
    AND stitched.ClassPath NOT LIKE 'com.reactnative.%'
    AND stitched.ClassPath NOT LIKE 'com.tbuonomo.%'
    AND stitched.ClassPath NOT LIKE 'com.google.accompanist.%'
    AND stitched.ClassPath NOT LIKE 'com.canhub.%'
    AND stitched.ClassPath NOT LIKE 'io.socket.%'
    AND stitched.ClassPath NOT LIKE 'com.mr.flutter.%'
    AND stitched.ClassPath NOT LIKE 'io.ionic.keyboard.%'
    AND stitched.ClassPath NOT LIKE 'gnu.%'
    AND stitched.ClassPath NOT LIKE 'kawa.%'
    AND stitched.ClassPath NOT LIKE 'com.google.youngandroid.%'
    AND stitched.ClassPath NOT LIKE 'net.lingala.%'
    AND stitched.ClassPath NOT LIKE 'uk.co.whiteoctober.%'
    AND stitched.ClassPath NOT LIKE 'com.lwansbrough.%'


    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.applovin.%'
    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.ironsrc.%'
    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.adcolony.%'
    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.vungle.%'
    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.inmobi.%'
    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.mmadbridge.%'
    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.fyber.%'
    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.bytedance2.%'
    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.startapp.%'
    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.smaato.%'
    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.corpmailru.%'
    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.startio.%'
    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.appodeal.%'
    AND stitched.ClassPath NOT LIKE 'com.iab.omid.library.amazon.%'

ORDER BY stitched.agg DESC;

