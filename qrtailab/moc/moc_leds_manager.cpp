/****************************************************************************
** Meta object code from reading C++ file 'leds_manager.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.6)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/leds_manager.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'leds_manager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.6. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_QRL_LedsManager[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       4,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
      17,   16,   16,   16, 0x0a,
      35,   30,   16,   16, 0x0a,
      68,   16,   16,   16, 0x0a,
      88,   16,   16,   16, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_QRL_LedsManager[] = {
    "QRL_LedsManager\0\0showLed(int)\0item\0"
    "showLedOptions(QListWidgetItem*)\0"
    "changeLedColor(int)\0refresh()\0"
};

void QRL_LedsManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        QRL_LedsManager *_t = static_cast<QRL_LedsManager *>(_o);
        switch (_id) {
        case 0: _t->showLed((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 1: _t->showLedOptions((*reinterpret_cast< QListWidgetItem*(*)>(_a[1]))); break;
        case 2: _t->changeLedColor((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 3: _t->refresh(); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData QRL_LedsManager::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject QRL_LedsManager::staticMetaObject = {
    { &QDialog::staticMetaObject, qt_meta_stringdata_QRL_LedsManager,
      qt_meta_data_QRL_LedsManager, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &QRL_LedsManager::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *QRL_LedsManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *QRL_LedsManager::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_QRL_LedsManager))
        return static_cast<void*>(const_cast< QRL_LedsManager*>(this));
    return QDialog::qt_metacast(_clname);
}

int QRL_LedsManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QDialog::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 4)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 4;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
