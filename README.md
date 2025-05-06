# ----------- اصدار الميكروتيك V6

#:set ($InNames->("ether1"))  ({"speed"=2; "username"="USERNAME"; "password"="PASSWORE"; "ip"="192.168.10.1"});
# ----------- المنفد بدل 
#---------- ether1
# مثال
:set ($InNames->("ether13"))
# ----------- السرعة غير الرقم فقط
#---------- speed=2 
# ----------- اذاكان بردج غير 
#        USERNAME
#        PASSWORE
# مثال
#---------- "username"="A234342"; "password"="12345";
# ----------- اذا كان دمح عادي امسح اسم المستخدم وكلمة السر واكتب الايبي والسرعة
# مثال

:set ($InNames->("ether1"))  ({"speed"=2; "ip"="192.168.10.1"});

#  مثال على الدمج بردج
:set ($InNames->("ether1"))  ({ "speed"=2; "username"="A123"; "password"="123456"  });
:set ($InNames->("ether2"))  ({ "speed"=4; "username"="B123"; "password"="123456"  });
#  مثال على الدمج العادي
:set ($InNames->("ether2"))  ({ "speed"=4; "ip"="192.168.11.1" });
:set ($InNames->("ether3"))  ({ "speed"=8; "ip"="192.168.12.1" });
# اذا تريد تحذف الدمج 
:do {
/ip route remove  [find where comment="Eng-Osamah-AutoLoadBalancing"];
/ip firewall nat remove [find where comment="Eng-Osamah-AutoLoadBalancing"];
/ip firewall mangle remove [find where comment="Eng-Osamah-AutoLoadBalancing"];
/interface pppoe-client remove [find where comment="Eng-Osamah-AutoLoadBalancing"];
/ip address remove [find where comment="Eng-Osamah-AutoLoadBalancing"];
/interface list member remove [find where comment="Eng-Osamah-AutoLoadBalancing"];
/interface list remove [find where (name="DAMGPPP" || name="DMGWAN" || name="DMGLAN" || comment="Eng-Osamah-AutoLoadBalancing")];
}

#  انسخ السطر وكرر العملية
# {} انسخ كامل مع الاقواس 



