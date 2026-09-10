<div align="center">

# Nexis Needs FX

**نظام مؤثرات احتياجات خفيف لـ FiveM مع صوت 3D مكاني واقعي للاعبين القريبين.**

`QBCore` · `3D Spatial Audio` · `No External Audio Dependency`

</div>

---

## عن السكربت

**Nexis Needs FX** يضيف مؤثرات صوتية لحالة احتياجات اللاعب بطريقة أكثر واقعية، بحيث يسمع اللاعبون القريبون الصوت حسب **المسافة والاتجاه** بدل أن يكون صوتًا محليًا ثابتًا.

## المميزات

- صوت **3D Spatial Audio** للاعبين القريبين.
- تدرج تلقائي للصوت حسب المسافة.
- تحديد اتجاه مصدر الصوت يمين / يسار / أمام / خلف.
- بدون `xSound` أو أي اعتماد صوتي خارجي.
- إعدادات بسيطة للمسافة ومستوى الصوت والتدرج.
- تنبيه للجوع والعطش قابل للتعديل.
- توافق مع حدث الجوع القديم في QBCore.
- خفيف وبنية ملفات منظمة.

## المتطلبات

- `qb-core`

## التركيب

ضع المجلد باسم `nexis-needsfx` داخل مجلد الـ resources، ثم أضف إلى `server.cfg`:

```cfg
ensure nexis-needsfx
```

يمكن تعديل إعدادات الصوت والاحتياجات من ملف `config.lua`.

## إعدادات الصوت

```lua
Config.Audio = {
    Radius = 10.0,
    FullVolumeDistance = 1.25,
    Volume = 0.34,
    Falloff = 1.65,
    UpdateInterval = 75,
    MaxPlaybackTime = 6000,
    ServerCooldown = 20000
}
```

`Radius` يحدد أقصى مسافة لسماع الصوت، و`Volume` مستوى الصوت الأساسي، و`Falloff` يتحكم في تدرج انخفاض الصوت مع الابتعاد.

---

<div align="center">

**Nexis Development**  
© Nexis Development. All rights reserved.

</div>
