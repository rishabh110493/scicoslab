/****************************************************************************
** Meta object code from reading C++ file 'led.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.6)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/qtplotlib/led.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'led.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.6. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_QPL_Led[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       4,   14, // methods
       2,   34, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
       9,    8,    8,    8, 0x0a,
      24,    8,    8,    8, 0x0a,
      41,    8,    8,    8, 0x0a,
      55,    8,    8,    8, 0x0a,

 // properties: name, type, flags
      77,   72, 0x01095103,
      90,   83, 0x43095103,

       0        // eod
};

static const char qt_meta_stringdata_QPL_Led[] = {
    "QPL_Led\0\0setValue(bool)\0setColor(QColor)\0"
    "toggleValue()\0setText(QString)\0bool\0"
    "value\0QColor\0color\0"
};

void QPL_Led::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        QPL_Led *_t = static_cast<QPL_Led *>(_o);
        switch (_id) {
        case 0: _t->setValue((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 1: _t->setColor((*reinterpret_cast< QColor(*)>(_a[1]))); break;
        case 2: _t->toggleValue(); break;
        case 3: _t->setText((*reinterpret_cast< QString(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData QPL_Led::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject QPL_Led::staticMetaObject = {
    { &QWidget::staticMetaObject, qt_meta_stringdata_QPL_Led,
      qt_meta_data_QPL_Led, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &QPL_Led::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *QPL_Led::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *QPL_Led::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_QPL_Led))
        return static_cast<void*>(const_cast< QPL_Led*>(this));
    return QWidget::qt_metacast(_clname);
}

int QPL_Led::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QWidget::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 4)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 4;
    }
#ifndef QT_NO_PROPERTIES
      else if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< bool*>(_v) = value(); break;
        case 1: *reinterpret_cast< QColor*>(_v) = color(); break;
        }
        _id -= 2;
    } else if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: setValue(*reinterpret_cast< bool*>(_v)); break;
        case 1: setColor(*reinterpret_cast< QColor*>(_v)); break;
        }
        _id -= 2;
    } else if (_c == QMetaObject::ResetProperty) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyDesignable) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyScriptable) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyStored) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyEditable) {
        _id -= 2;
    } else if (_c == QMetaObject::QueryPropertyUser) {
        _id -= 2;
    }
#endif // QT_NO_PROPERTIES
    return _id;
}
QT_END_MOC_NAMESPACE
