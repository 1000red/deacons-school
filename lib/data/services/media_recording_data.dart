import '../models/models.dart';

class MediaRecordingData {
  MediaRecordingData._();

  static const _driveIds = <String, String>{
    // ==== preparatory ====
    // ===== السنة الأولى =====
    // Hymns
    'preparatory/preparatory_y1/t1/hymns/ختام الصلاة الربانية':
        '1NV-hbss3Eopbi9viVYC7PQmtksDgShJV',
    'preparatory/preparatory_y1/t1/hymns/مرد البولس المختصر"تين اووشت"':
        '1CO5rVP8OZJsBaR8Sr_jgjD5msuetYqMb',
    'preparatory/preparatory_y1/t1/hymns/مرد الابركسيس المختصر"اك اسماروؤت"':
        '1BaNS-57EVQVN1q_wGMOXtsCFKot70iiF',
    'preparatory/preparatory_y1/t1/hymns/مرد انجيل شهر كيهك':
        '1bUwMWhyGENV7yqtM1b5d3_J0XqRsKrXR',
    'preparatory/preparatory_y1/t1/hymns/مرد انجيل عيد الميلاد':
        '14hv2ehT30uAumtIE_5JYGnSFfAbEppq5',
    'preparatory/preparatory_y1/t1/hymns/مرد ثيؤطوكية يوم الاربعاء':
        '1sp3vEv3sL1TCvequJ5CHsJOuDqLik6XV',

    // Coptic
    'preparatory/preparatory_y1/t1/coptic/حرف الفا (Ⲁ ⲁ)': '',
    'preparatory/preparatory_y1/t1/coptic/حرف بيتا (Ⲃ ⲃ)': '',
    'preparatory/preparatory_y1/t1/coptic/حرف غما (Ⲅ ⲅ)': '',
    'preparatory/preparatory_y1/t1/coptic/حرف ذلتا (Ⲇ ⲇ)': '',
    'preparatory/preparatory_y1/t1/coptic/حرف اي (Ⲉ ⲉ)': '',
    'preparatory/preparatory_y1/t1/coptic/حرف سو (ⲋ)': '',
    'preparatory/preparatory_y1/t1/coptic/حرف زيتا (Ⲍ ⲍ)': '',
    'preparatory/preparatory_y1/t1/coptic/حرف ايتا (Ⲏ ⲏ)': '',

    // ===== السنة الثانية =====
    // Hymns
    'preparatory/preparatory_y1/t2/hymns/مرد انجيل العشية السنوي':
        '1sFdBeaieX-brkWR1APkwv7fYniSKULrj',
    'preparatory/preparatory_y1/t2/hymns/مردات الانافورا:':
        '1SvDGoCbP0PiYSmDPUe2FjC9EGue_yC7N',
    'preparatory/preparatory_y1/t2/hymns/مردات الشماس بعد الرشومات':
        '1WE5hH8witGLiznjvR7irXXPX3i8YppR3',
    'preparatory/preparatory_y1/t2/hymns/مرد مزمور التوزيع في الصوم الكبير':
        '1sHG6mQJDJn9fcfjRIzdoVzgw_y0CxE6u',
    'preparatory/preparatory_y1/t2/hymns/مرد الشعانين':
        '11H_hJ3iymI9trTj9e_phT5f9wIkBVzyC',
    'preparatory/preparatory_y1/t2/hymns/توك تي تي جوم':
        '1JyWRPLSdUGH9l1JIzCNfiHMbR5-ie-CQ',

    // Coptic
    'preparatory/preparatory_y1/t2/coptic/حرف يوطا (Ⲓ ⲓ)': '',
    'preparatory/preparatory_y1/t2/coptic/حرف ثيتا (Ⲑ ⲑ)': '',
    'preparatory/preparatory_y1/t2/coptic/حرف لولا (Ⲗ ⲗ)': '',
    'preparatory/preparatory_y1/t2/coptic/حرف كبا (Ⲕ ⲁ)': '',
    'preparatory/preparatory_y1/t2/coptic/حرف مي (Ⲙ ⲙ)': '',
    'preparatory/preparatory_y1/t2/coptic/حرف ني (Ⲛ ⲛ)': '',
    'preparatory/preparatory_y1/t2/coptic/حرف اوميكرون (Ⲟ ⲟ):': '',
    'preparatory/preparatory_y1/t2/coptic/حرف اكسي (Ⲯ ⲯ)': '',

    // ===== السنة الثالثة =====
    // Hymns
    'preparatory/preparatory_y1/t3/hymns/كيري ليسون الحمل':
        '1h5graxxmaypzcffjxg76C9R1NToa_VvS',
    'preparatory/preparatory_y1/t3/hymns/مرد صلاة الصلح للقداس الباسيلي "بشفاعات"':
        '1ol-nj-9HKslrU-yrJ3j9lrlBVMtt0g4P',
    'preparatory/preparatory_y1/t3/hymns/مردات مقدمة القسمة الباسيلي':
        '13VPAtUL6FgluklVQ4zL4N3Fu0wU6GFhy',
    'preparatory/preparatory_y1/t3/hymns/مرد مزمور التوزيع في الصوم الكبير':
        '1ByMTTIUVwrNV3AB_kqLNcbqza-kj4tyx',
    'preparatory/preparatory_y1/t3/hymns/مرد المزمور لعيد القيامة':
        '19RZrREs8drIioeyEInxKZ8ZqVKeixJJS',
    'preparatory/preparatory_y1/t3/hymns/مرد الانجيل لعيد القيامة':
        '1Z9netUlr9fjZ3S2B9-dP5Kok5ksRsSxW',
    'preparatory/preparatory_y1/t3/hymns/مرد صعد الى اعلى السماوات':
        '17Qn-WU-eYf4akc_3gxdk--NseclD0rkt',
    'preparatory/preparatory_y1/t3/hymns/مرد لحن راشي ني " للعذراء والانبا انطونيوس"':
        '16XGMiFO8bArslZL_c04RKGX4ZmG-2jy0',
    'preparatory/preparatory_y1/t3/hymns/مرد عيد الصليب':
        '1RDmjMjSHVMIvTQkisgf8UHHPFEtS2tAI',
    'preparatory/preparatory_y1/t3/hymns/مرد ختام الصلوات الاجتماعية':
        '1hW1VeamIH_-tmKp42A17GxGKSYQUMcNp',
    'preparatory/preparatory_y1/t3/hymns/مردات الثيوطوكيات':
        '1Kz5br3jsEoNLgZN4GK8oyB7lAkBKgf5H',

    // Coptic
    'preparatory/preparatory_y1/t3/coptic/حرف رو (Ⲣ ⲣ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف بي (Ⲡ ⲡ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف سيما (Ⲥ ⲁ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف تاف (Ⲧ ⲧ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف ابسيلون (Ⲩ ⲩ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف فيي (Ⲫ ⲫ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف كي (Ⲭ ⲭ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف ابسي (Psi psi)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف اوميجا (Ⲱ ⲱ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف شاي (Ϣ ϣ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف فاي (Ϥ ϥ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف خاي (Ϧ ϧ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف هوري (Ϩ ϩ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف چنجا (Ϫ ϫ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف تشيما (Ϭ ϭ)': '',
    'preparatory/preparatory_y1/t3/coptic/حرف تي (Ϯ ϯ)': '',
    // ===== المستوى الثالث (third) =====
    // ===== السنة الأولى =====

    // ===== الترم الأول =====
    // Hymns
    'third/third_y1/t1/hymns/أوشية المياه: 12 بؤونه إلى 9 بابه':
        '1iRIRYY9mv09WoVxGcKNPBqo46UVBw0SA',
    'third/third_y1/t1/hymns/أوشية الزروع: ومن 10 بابه إلى 10 طوبه':
        '16EreQIjXyDgzCqVEa-zVvjMWVXMd1MRt',
    'third/third_y1/t1/hymns/أوشية الثمار (أهوية السماء): 11 طوبه إلى 11 بؤونه':
        '17J_gIf5xP2FlhkkE2cTGHMtsvvctfivK',
    'third/third_y1/t1/hymns/ذكصولوجية الآباء الرسل (كيريوس إيسوس / الرب يسوع)':
        '1XB5FjjSI3t3dK0DPI2lox3WqY7I8iTLe',
    'third/third_y1/t1/hymns/لحن ايبارثينوس:':
        '1MnWkkRhBooMPSrqcz8gfNra0BOYR5Hdu',
    'third/third_y1/t1/hymns/لحن بي جين ميسي:':
        '1dYpfAsUSZN0oKbxvdOz4sClSjJyou2WI', // same audio as ايبارثينوس
    'third/third_y1/t1/hymns/لحن محير عيد الميلاد:':
        '1BUTaO-KvcGdiQ6sSTC4AMmPf3DoHul0o',
    'third/third_y1/t1/hymns/لحن مرد إنجيل عيد الميلاد:':
        '1FDKcm_LAe3jY8f1SsW5c7IuOePiNbQqI',
    'third/third_y1/t1/hymns/لحن مرد مزمور عيد الميلاد:':
        '1Ceq5Pw6jffraF48yEoa63u60QriqJTZT',

    // Coptic
    'third/third_y1/t1/coptic/حرف ألفا (Ⲁⲁ)': '',
    'third/third_y1/t1/coptic/حرف فيتا (Bß)': '',
    'third/third_y1/t1/coptic/حرف غما (Ɣϛ)': '',
    'third/third_y1/t1/coptic/حرف ذلتا (Ⲇⲇ)': '',
    'third/third_y1/t1/coptic/حرف اى (اپسيلون) (Ⲉⲉ)': '',
    'third/third_y1/t1/coptic/حرف سو (Ϛϛ)': '',
    'third/third_y1/t1/coptic/حرف زيتا (Ζζ)': '',
    'third/third_y1/t1/coptic/حرف ايتا (Ⲏⲏ)': '',
    'third/third_y1/t1/coptic/جدول العشرات والمئات': '',

    // ===== الترم الثاني =====
    // Hymns
    'third/third_y1/t2/hymns/لحن مقدمة الإنجيل "من أجل أن نكون مستحقين، كيه إيبرتو":':
        '1w5RxJz7JIph9kiKZTm4xe9CfgP6g4uQa',
    'third/third_y1/t2/hymns/لحن انثو تيه تي شوري:':
        '1QmGk1BoJFpjY9x0-IFJG62GnAaWnEAlC',
    'third/third_y1/t2/hymns/لحن خريستوس أنيستى الكبير:':
        '1YqdYRb8SNp550uz-W552Fck9L0WB1uK4',

    // Coptic
    'third/third_y1/t2/coptic/حرف يوطا (Ⲓⲓ)': '',
    'third/third_y1/t2/coptic/حرف ثيتا (Ⲑⲑ)': '',
    'third/third_y1/t2/coptic/حرف كبا (Ⲕⲕ)': '',
    'third/third_y1/t2/coptic/حرف لولا (Ⲗⲗ)': '',
    'third/third_y1/t2/coptic/حرف مى (Ⲙⲙ)': '',
    'third/third_y1/t2/coptic/حرف نى (Ⲛⲛ)': '',
    'third/third_y1/t2/coptic/حرف اكسى (Ⲝⲝ)': '',
    'third/third_y1/t2/coptic/حرف او (Ⲟⲟ)': '',
    'third/third_y1/t2/coptic/حرف بى (Ⲡⲡ)': '',
    'third/third_y1/t2/coptic/حرف رو (Ⲣⲣ)': '',
    'third/third_y1/t2/coptic/جدول الاحاد': '',
    'third/third_y1/t2/coptic/جدول العشرات والمئات': '',

    // ===== الترم الثالث =====
    // Hymns
    'third/third_y1/t3/hymns/لحن البولس السنوي:':
        '1puitBVMtPcyCfjm8c5VzX5Ev3hGrPOpN',
    'third/third_y1/t3/hymns/لحن البولس الحزايني إثڤيه تي أناسطاسيس:':
        '13XXAO1gJ34h4j6K9tm95BC1OrmOVjbP-',
    'third/third_y1/t3/hymns/مقدمة تسبحة نصف الليل:':
        '1SrnwfwleSN6LiO3cJER5k2HAV2QXYqfZ',
    'third/third_y1/t3/hymns/الاسبزموس الآدام "أفرحي يا مريم":':
        '1EdBfUpYVCXiPInkHamF_wVSS1PPvgDZs',
    'third/third_y1/t3/hymns/الهوس الاول:': '10iF_V3YCvSmqBBZ7c3fhldOk9IliLHHx',
    'third/third_y1/t3/hymns/لحن استقبال الاب البطريرك و الاب الاسقف:':
        '14PFCi9dfo9Jvrx9PL9X7oOy4ypUUPXOS',
    'third/third_y1/t3/hymns/الهيتينية الكبيرة:':
        '15K_ChNrKLJ5hIYvK_YAzMW2n5iu7x8v-',
    'third/third_y1/t3/hymns/لبش الهوس الأول (خين أوشوت):':
        '1_JCZQyf4iD-LPmyzDaUOtmgjgWB3ZhHk',

    // Coptic
    'third/third_y1/t3/coptic/حرف سيما (Ⲥⲥ)': '',
    'third/third_y1/t3/coptic/حرف طاف (Ⲧⲧ)': '',
    'third/third_y1/t3/coptic/حرف ابسلون (Ⲩⲩ)': '',
    'third/third_y1/t3/coptic/حرف في (Ⲫⲫ)': '',
    'third/third_y1/t3/coptic/حرف كي (Ⲭⲭ)': '',
    'third/third_y1/t3/coptic/حرف ابسي (Ⲯⲯ)': '',
    'third/third_y1/t3/coptic/حرف أو (Ⲱⲱ)': '',
    'third/third_y1/t3/coptic/حرف شاي (Ϣϣ)': '',
    'third/third_y1/t3/coptic/حرف فاي (Ϥϥ)': '',
    'third/third_y1/t3/coptic/حرف خاي (Ϧϧ)': '',
    'third/third_y1/t3/coptic/حرف هوري (Ϩϩ)': '',
    'third/third_y1/t3/coptic/حرف جنجا (Ϫϫ)': '',
    'third/third_y1/t3/coptic/حرف تشيما (Ϭϭ)': '',
    'third/third_y1/t3/coptic/حرف تي (Ϯϯ)': '',
    'third/third_y1/t3/coptic/جدول العشرات والمئات (تكملة)': '',
    // ===== السنة الثانية=====

    // ===== الترم الأول =====
    // Hymns
    'third/third_y2/t1/hymns/ذكصولوجية الانبا بولا:':
        '1ZxEOdjYEd0HlQu-XKbWY994H5hMp84HJ',
    'third/third_y2/t1/hymns/ذكصولوجية الانبا انطونيوس والانبا بولا:':
        '1v227cmP7HAPC2QFPP2UCnEBGdGRmJrM5',
    'third/third_y2/t1/hymns/مرد بي نيشتي الصغيرة:':
        '1GNaUoJaND5oszV3Aj762ECmHoNPBqsy1',
    'third/third_y2/t1/hymns/مرد اوشية القرابين:':
        '136gidAbw3rL6nlTqPJ5A-bPzt7oQoWU5',
    'third/third_y2/t1/hymns/الختام الكبير لمرد الابركسيس السنوي ويركب عليه مرد الابركسيس لقداس عيد الميلاد المجيد:':
        '1FxfXqewN1ZzDPqy-AEitr3VGM8OUXS0S',

    // Coptic
    'third/third_y2/t1/coptic/حرف الفا (Ⲁ ⲁ)': '',
    'third/third_y2/t1/coptic/حرف فيتا (Ⲃ ⲃ)': '',
    'third/third_y2/t1/coptic/حرف غما (Ⲅ ⲅ)': '',
    'third/third_y2/t1/coptic/حرف دلتا (Ⲇ ⲇ)': '',
    'third/third_y2/t1/coptic/حرف اي (Ⲉ ⲉ)': '',
    'third/third_y2/t1/coptic/حرف سو (ⲋ̅)': '',
    'third/third_y2/t1/coptic/حرف زيتا (Ⲍ ⲍ)': '',
    'third/third_y2/t1/coptic/حرف ثيتا (Ⲑ ⲑ)': '',
    'third/third_y2/t1/coptic/حرف يوطا (Ⲓ ⲓ)': '',
    'third/third_y2/t1/coptic/حرف ايتا (Ⲏ ⲏ)': '',

    // ===== الترم الثاني =====
    // Hymns
    'third/third_y2/t2/hymns/لحن اجيوس الحزايني الكبير':
        '1T9H7Hh6xm7i3T-GFnY0ZVkxLvjCc2vKp',
    'third/third_y2/t2/hymns/مرد الإبركسيس في ايام الصوم الكبير / شاريه افنوتي':
        '1LJvnSxmBpzuOPk7zAUFoae85AmuPjqbl',
    'third/third_y2/t2/hymns/لحن خريستوس أنيستي الصغيرة':
        '1g9kYgDSoapRULhAknjZ3-Fby3bnfjnLH',
    'third/third_y2/t2/hymns/لحن طوليثوس': '1JRwI83E3KK45W0vCmJ3tfEN2j0VFy0Zw',

    // Coptic
    'third/third_y2/t2/coptic/قواعد نطق بعض الحروف القبطية': '',

    // ===== الترم الثالث =====
    // Hymns
    'third/third_y2/t3/hymns/الكاثوليكون قبطى':
        '1jqzJlDO0JDTR4-Ce8y8kX2c3O5FSsAO_',
    'third/third_y2/t3/hymns/الأسبسمس الواطس السنوى / أيها الرب إله القوات':
        '1pga1QMES3ofvYnc3oOBZsHsBwkpD62yQ',
    'third/third_y2/t3/hymns/الهوس الثانى': '1Y2I44W-Za7CZR6LmMVfXAid51V8SUj9L',
    'third/third_y2/t3/hymns/لبش الهوس الثانى / مارين أووأونه':
        '143oiHVFbVxZdStBkETgMQ-xbs5aX_mzp',
    'third/third_y2/t3/hymns/الهوس الرابع (مزمور 148، 149، 150)':
        '1wVAdwbE4YjN2NyccCqEiwMmRXbuVPXTA',
    'third/third_y2/t3/hymns/لحن إبؤرو الفرايحي':
        '1zCblk1C9e6weEDUFFVsuJ5rdYoh8Zd3z',
    'third/third_y2/t3/hymns/لحن الصليب / فاى إيطاف إنف':
        '14-Rk8fjxCu7Ks-EINxTyuqqJZ2E5FtyX',

    // Coptic
    'third/third_y2/t3/coptic/حرف بي (Ⲡ)': '',
    'third/third_y2/t3/coptic/حرف رو (Ⲣ)': '',
    'third/third_y2/t3/coptic/حرف سيما (Ⲥ)': '',
    'third/third_y2/t3/coptic/حرف تاف (Ⲧ)': '',
    'third/third_y2/t3/coptic/حرف ابسيلون (Ⲩ)': '',
    'third/third_y2/t3/coptic/حرف فى (Ⲫ)': '',
    'third/third_y2/t3/coptic/حرف كى (Ⲭ)': '',
    'third/third_y2/t3/coptic/حرف پسى (Psi)': '',
    'third/third_y2/t3/coptic/حرف أوميجا (Ⲱ)': '',
    'third/third_y2/t3/coptic/حرف الفى (Ϣ)': '',
    'third/third_y2/t3/coptic/حرف خاى (Ϧ)': '',
    'third/third_y2/t3/coptic/حرف هوريع (Ϩ)': '',
    'third/third_y2/t3/coptic/حرف جانجيا (Ϫ)': '',
    'third/third_y2/t3/coptic/حرف تشيما (Ϭ)': '',
    'third/third_y2/t3/coptic/حرف تى (Ϯ)': '',
    'third/third_y2/t3/coptic/آيات للحفظ': '',

    // ===== السنة الثالثة =====
    // ===== الترم الأول =====
    // Hymns
    'third/third_y3/t1/hymns/المزمور السنجارى الوسط  لقداس عيد الميلاد المجيد :':
        '1OTJaODad4UPTYFFMJMzgHxpvEnxt4LRB',
    'third/third_y3/t1/hymns/امين الطويلة ختام المجمع الباسيلي لمرد إريه بو إسمو ومرد اوس بيرين:':
        '15cXVWBjUhDoSKZjJkoXbUYM_p8Z9Iyyj',
    'third/third_y3/t1/hymns/مرد امين الطويلة ختام مقدمة القسمة الباسيلي ومرد قطعة (وايضا فلنشكر الله الأب ضابط الكل):':
        '11b1E3h3fN0Tqi4PTtmwVi2EBB61qZkUn',
    'third/third_y3/t1/hymns/مرد هيتين ني ابريسفيا ومردات الأنافورا للقداس الغريغوري:':
        '1X8r9PhQgBfSmVjf3YpL6DM6P9a8Lqoi4',

    // Coptic
    'third/third_y3/t1/coptic/حرف الألفا (Ⲁⲁ) - مراجعة': '',
    'third/third_y3/t1/coptic/حرف الفيتا (Ⲃⲃ) - مراجعة': '',
    'third/third_y3/t1/coptic/حرف الغما (Ɣϛ) - مراجعة': '',
    'third/third_y3/t1/coptic/حرف الدلتا (Ⲇⲇ) - مراجعة': '',
    'third/third_y3/t1/coptic/حرف الإيه (Ⲉⲉ) - مراجعة': '',
    'third/third_y3/t1/coptic/حرف السو': '',
    'third/third_y3/t1/coptic/حرف الزيتا (Ζζ) - مراجعة': '',
    'third/third_y3/t1/coptic/حرف الأيتا (Ⲏⲏ) - مراجعة': '',
    'third/third_y3/t1/coptic/حرف الثيتا (Ⲑⲑ) - مراجعة': '',
    'third/third_y3/t1/coptic/حرف اليوتا (Ⲓⲓ) - مراجعة': '',

    // ===== الترم الثاني =====
    // Hymns
    'third/third_y3/t2/hymns/اللى التوزيع الصيامى والمزمور قبطى وعربى :':
        '19tv5ZxmqH27E6NWnYLObp6m6KmgWTbG7',
    'third/third_y3/t2/hymns/قانون الدفنة – لحن غولغوثا :':
        '1BAHG8pJ3osQaJXavhaVyXZKsdxT2e3wV',
    'third/third_y3/t2/hymns/لحن القيامة – يا كل الصفوف:':
        '1W6rNCfW83XxOb2BlHY1UIZZM2dKYTKwc',
    'third/third_y3/t2/hymns/الانجيل بالطريقة الحزايني – إنجيل الساعة الحادية عشر من يوم الثلاثاء الكبير:':
        '1ZxN5XlW5UHoBbJmIsmRxkEpC2TyXJBvG',

    // Coptic
    'third/third_y3/t2/coptic/حرف كبا (Ⲕⲕ) - مراجعة': '',
    'third/third_y3/t2/coptic/حرف لولا (Ⲗⲗ) - مراجعة': '',
    'third/third_y3/t2/coptic/حرف مي (Ⲙⲙ) - مراجعة': '',
    'third/third_y3/t2/coptic/حرف ني (Ⲛⲛ) - مراجعة': '',
    'third/third_y3/t2/coptic/حرف اكسي (Ⲝⲝ) - مراجعة': '',
    'third/third_y3/t2/coptic/حرف أو (Ⲟⲟ) - مراجعة': '',
    'third/third_y3/t2/coptic/حرف بي (Ⲡⲡ) - مراجعة': '',
    'third/third_y3/t2/coptic/حرف رو (Ⲣⲣ) - مراجعة': '',

    // ===== الترم الثالث =====
    // Hymns
    'third/third_y3/t3/hymns/لحن مقدمة الإبركسيس السنوي :':
        '1LyU3fPar_NlpNilexD9xSZKWMMyHxEHw',
    'third/third_y3/t3/hymns/الهوس الثالث – تسبحة الثلاثة فتية القديسين:':
        '1KM5piUK4q-zUk_bUWGyC4LQPXJs54Ddg',
    'third/third_y3/t3/hymns/لحن إسمو إبتشويس / لحن أرى هوؤ تشاسف':
        '1acNpVzOu0Lfv5HK3qFkhrE5zCd1zAEMp',
    'third/third_y3/t3/hymns/إبصالية إريبسالين / إبصالية واطس الثلاثة فتية القديسين:':
        '1AQG95uROyUF4jw6BsorRnaHy8yDS395L',
    'third/third_y3/t3/hymns/القطعه السابعة من ثيؤطوكية يوم الأحد :':
        '1GeuaIn2PGw6NgTsTOsmk7AMRCuRN7xYo',
    'third/third_y3/t3/hymns/لحن شيرى ني ماريا :':
        '1vU3tDbPx54PhAsIhfUPij1xctm22Z0x6',
    'third/third_y3/t3/hymns/اللى التوزيع السنوي والمزمور ال 150:':
        '1HFwP7mnjBgfTlybp7Vnqa2yP4waaBREP',
    'third/third_y3/t3/hymns/التوزيع: لحن بي أويك / خبز الحياة:':
        '15RtKw64lnfnefDNS7WdH4Y6IT0xLuY4w',

    // Coptic
    'third/third_y3/t3/coptic/حرف سيما (Ⲥⲥ) - مراجعة': '',
    'third/third_y3/t3/coptic/حرف طاف (Ⲧⲧ) - مراجعة': '',
    'third/third_y3/t3/coptic/حرف ابسلون (Ⲩⲩ) - مراجعة': '',
    'third/third_y3/t3/coptic/حرف في (Ⲫⲫ) - مراجعة': '',
    'third/third_y3/t3/coptic/حرف كي (Ⲭⲭ) - مراجعة': '',
    'third/third_y3/t3/coptic/حرف ابسي (Ⲯⲯ) - مراجعة': '',
    'third/third_y3/t3/coptic/حرف أوميجا (Ⲱⲱ) - مراجعة': '',
    'third/third_y3/t3/coptic/حرف شاي (Ϣϣ) - مراجعة': '',
    'third/third_y3/t3/coptic/حرف فاي (Ϥϥ) - مراجعة': '',
    'third/third_y3/t3/coptic/حرف خاي (Ϧϧ) - مراجعة': '',
    'third/third_y3/t3/coptic/حرف هوري (Ϩϩ) - مراجعة': '',
    'third/third_y3/t3/coptic/حرف جنجا (Ϫϫ) - مراجعة': '',
    'third/third_y3/t3/coptic/حرف تشيما (Ϭϭ) - مراجعة': '',
    'third/third_y3/t3/coptic/حرف تي (Ϯϯ) - مراجعة': '',
    'third/third_y3/t3/coptic/آيات للحفظ بالقبطية': '',
  };

  static String? driveFileId(NavPath path, String lessonTitle) {
    final id = _driveIds['${path.curriculumKey}/$lessonTitle'];
    return id == null || id.isEmpty ? null : id;
  }

  static String? audioUrl(NavPath path, String lessonTitle) {
    final id = driveFileId(path, lessonTitle);
    if (id == null) return null;
    // رابط مباشر بلا إعادة توجيه؛ أنسب لـ audioplayers على الموبايل.
    return 'https://drive.usercontent.google.com/download?'
        'id=$id&export=download&authuser=0&confirm=t';
  }

  /// يحول أي رابط مشاركة من Google Drive إلى رابط مناسب لمشغّل الصوت.
  /// هذا هو المكان الوحيد المسؤول عن صيغة روابط Drive في التطبيق.
  static String? playableUrl(String? url) {
    if (url == null || url.isEmpty || !url.contains('drive.google.com')) {
      return url;
    }

    if (url.contains('export=download')) return url;

    final fileMatch = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(url);
    final idMatch = RegExp(r'[?&]id=([a-zA-Z0-9_-]+)').firstMatch(url);
    final fileId = fileMatch?.group(1) ?? idMatch?.group(1);

    return fileId == null
        ? url
        : 'https://drive.usercontent.google.com/download?'
            'id=$fileId&export=download&authuser=0&confirm=t';
  }
}
