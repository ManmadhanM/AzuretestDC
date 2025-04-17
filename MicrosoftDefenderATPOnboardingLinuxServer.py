




#!/usr/bin/env python

import sys, getopt, os, errno, json, subprocess, tempfile

def usage():
    print ("""Usage: %s
    Performs onboarding\offboarding to WDATP locally
""" % sys.argv[0])
    pass

try:
    opts, args = getopt.getopt(sys.argv[1:], 'hc', ['help', 'config='])

    for k, v in opts:
        if k == '-h' or k == '--help':
            usage()
            sys.exit(0)

except getopt.GetoptError as e:
    print (e)
    print ('')
    usage()
    sys.exit(2)

try:
    destfile = '/etc/opt/microsoft/mdatp/mdatp_onboard.json'

    if os.geteuid() != 0:
        print('Re-running as sudo (you may be required to enter sudo''s password)')
        os.execvp('sudo', ['sudo', 'python'] + sys.argv)  # final version

    print('Generating %s ...' % destfile)

    cmd = "sudo mkdir -p '%s'" % (os.path.dirname(destfile))
    subprocess.check_call(cmd, shell = True)

    with open(destfile, "w") as json:
        json.write('''{
  "onboardingInfo": "{\\\"body\\\":\\\"{\\\\\\\"previousOrgIds\\\\\\\":[],\\\\\\\"orgId\\\\\\\":\\\\\\\"492bafd5-2e01-453a-8cdb-3f6965db6b88\\\\\\\",\\\\\\\"geoLocationUrl\\\\\\\":\\\\\\\"https://winatp-gw-neu.microsoft.com/\\\\\\\",\\\\\\\"datacenter\\\\\\\":\\\\\\\"NorthEurope\\\\\\\",\\\\\\\"vortexGeoLocation\\\\\\\":\\\\\\\"EU\\\\\\\",\\\\\\\"version\\\\\\\":\\\\\\\"1.8\\\\\\\",\\\\\\\"deviceType\\\\\\\":\\\\\\\"Server\\\\\\\",\\\\\\\"packageGuid\\\\\\\":\\\\\\\"bce8083d-0bb9-4d59-81e0-7b761c2d3401\\\\\\\"}\\\",\\\"sig\\\":\\\"6P5XFRf+La7wGQBd8cv2ieJuyGULqleKrrzRQQMAsZCQTUW7htHWzG0nSsThYar0ZknemgAgbyv1M1INGIlXGHB/uNRb1jvrQIJVUe4iT1yAgwa+cCM4tx71bE54Ha0PCOIZWCD9q26OIwSKbOGihJFTO4/lGdeuqSj3Medaa0mF36rWTeXhqURVVESLj3ERlyd7zePV+GDdXsAV/ogfakQi5TEwY6IVtYf40GwmngsVvYghK8SCsTKkVF1tRPksmHmQNLLh7c8rFfMHV/TWRNwts4BFSMIOHCTMp+FWuxXRylt1Le6HDaEfKCcvXZQkOJ9sE1kqTU7Mh2ZeB+1VCQ==\\\",\\\"sha256sig\\\":\\\"6P5XFRf+La7wGQBd8cv2ieJuyGULqleKrrzRQQMAsZCQTUW7htHWzG0nSsThYar0ZknemgAgbyv1M1INGIlXGHB/uNRb1jvrQIJVUe4iT1yAgwa+cCM4tx71bE54Ha0PCOIZWCD9q26OIwSKbOGihJFTO4/lGdeuqSj3Medaa0mF36rWTeXhqURVVESLj3ERlyd7zePV+GDdXsAV/ogfakQi5TEwY6IVtYf40GwmngsVvYghK8SCsTKkVF1tRPksmHmQNLLh7c8rFfMHV/TWRNwts4BFSMIOHCTMp+FWuxXRylt1Le6HDaEfKCcvXZQkOJ9sE1kqTU7Mh2ZeB+1VCQ==\\\",\\\"cert\\\":\\\"MIIFgzCCA2ugAwIBAgITMwAAAwiuH9Ak1Zb1UAAAAAADCDANBgkqhkiG9w0BAQsFADB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQgU2VjdXJlIFNlcnZlciBDQSAyMDExMB4XDTI0MDgyMjIwMDYwOVoXDTI1MDgyMjIwMDYwOVowHjEcMBoGA1UEAxMTU2V2aWxsZS5XaW5kb3dzLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK5GSnNoBWBUybDN/NOY+j+X4jpWFU84ZKKhoLD3JX1vcDBKId/o0xOoKVMIqcDGmdsX6Fjit2XssI9wHXvKiJdk/v9SQhJYhG3tFoip9+RmK+DPn3lMKDJx6KHhd/AIlMmp+4Ma433+BmDgMAIvbZDm1xRH4t9SwKlvBBwoQEs4zR0Nbz/aEkL7rD1CHIjIt++hGUQ4VRLnS4RUVXwIuFzvKiBnAR3WSbW0vVr5nU6al/WSinxJ+sLglC1aWWLO3EAGHrN4Ohnm5JK7lqEmbNyv7W6KOyFqnKfiDrk/DsUD0SJycoPNleRnJRTfbb6Rfmpbyr+bOt8yL27YF+crC/0CAwEAAaOCAVgwggFUMA4GA1UdDwEB/wQEAwIFIDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwDAYDVR0TAQH/BAIwADAeBgNVHREEFzAVghNTZXZpbGxlLldpbmRvd3MuY29tMB0GA1UdDgQWBBQC/j4kVANjV6pF/RIxeCyCfnEKnDAfBgNVHSMEGDAWgBQ2VollSctbmy88rEIWUE2RuTPXkTBTBgNVHR8ETDBKMEigRqBEhkJodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNTZWNTZXJDQTIwMTFfMjAxMS0xMC0xOC5jcmwwYAYIKwYBBQUHAQEEVDBSMFAGCCsGAQUFBzAChkRodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY1NlY1NlckNBMjAxMV8yMDExLTEwLTE4LmNydDANBgkqhkiG9w0BAQsFAAOCAgEAQy6ejw037hwXvDPZF1WzHp/K0XxSHqr2WpixK3X3DHLuvcWaZJR8PhrsQGnjt+4epxrPaGdYgbj7TRLkFeKtUKiQIVfG7wbAXahHcknqhRkrI0LvWTfmLZtc4I2YXdEuKOnRoRIcbOT9NKBvc7N1jqweFPX7/6K4iztP9fyPhrwIHl544uOSRcrTahpO80Bmpz8n/WEVNQDc+ie+LI78adJh+eoiGzCgXSNhc8QbTKMZXIhzRIIf1fRKkAQxbdsjb/6kQ1hQ0u5RCd/eFCWODuCfpOAevJkn0rHmEzutbbFps/QdWwLyIj1HE+qTv5dNpYUx0oEGYtc83EIbGFZZyfrB6iDQvainmVp82La+Ahtw4+guVBLTSE7HKudob78WHX4WKBzJBKWUBlHM/lm67Qus28oU144qFMtsOg/rfN3J1J1ydT0GfulGJ8MR0+qJ9pk6ojv0W+F4mwuqkMWQuNAH9BL+5NkghtwBL0BwHpNyFtXzXiNf6s+cYuKGQsS4/ku4eczk/NRWryfXGjGM23zrpIsLkr5DCer34gjdTwn2TmQbWt+65pYyCpFc53v3ejCyTLz13O6JOFuXkL4K9QRqak9xtiGZik6EgTzKE4Ve6SIRFluxleV4UQ3XdzLb+903YD2Ke57PCpBHq/x35xcn+DzHVU3S2C/i43wUeKo=\\\",\\\"chain\\\":[\\\"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\\\"]}"
}''')

    cmd = "logger -p warning Microsoft ATP: succeeded to save json file %s." % (destfile)
    subprocess.check_call(cmd, shell = True)

except Exception as e:
    print(str(e))
    cmd = "logger -p error Microsoft ATP: failed to save json file %s. Exception occured: %s. " % (destfile, str(e))
    subprocess.call(cmd, shell = True)
    sys.exit(1)