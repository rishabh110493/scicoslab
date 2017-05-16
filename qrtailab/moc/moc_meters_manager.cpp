/****************************************************************************
** Meta object code from reading C++ file 'meters_manager.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.6)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/meters_manager.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'meters_manager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.6. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_QRL_MetersManager[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
      21,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
      19,   18,   18,   18, 0x0a,
      29,   18,   18,   18, 0x0a,
      49,   44,   18,   18, 0x0a,
      84,   18,   18,   18, 0x0a,
     106,   18,   18,   18, 0x0a,
     132,   18,   18,   18, 0x0a,
     150,   18,   18,   18, 0x0a,
     168,   18,   18,   18, 0x0a,
     185,   18,   18,   18, 0x0a,
     206,   18,   18,   18, 0x0a,
     227,   18,   18,   18, 0x0a,
     250,   18,   18,   18, 0x0a,
     276,   18,   18,   18, 0x0a,
     302,   18,   18,   18, 0x0a,
     325,   18,   18,   18, 0x0a,
     352,   18,   18,   18, 0x0a,
     377,   18,   18,   18, 0x0a,
     404,   18,   18,   18, 0x0a,
     424,   18,   18,   18, 0x0a,
     440,   18,   18,   18, 0x0a,
     467,   18,   18,   18, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_QRL_MetersManager[] = {
    "QRL_MetersManager\0\0refresh()\0"
    "showMeter(int)\0item\0"
    "showMeterOptions(QListWidgetItem*)\0"
    "showMeterOptions(int)\0changeRefreshRate(double)\0"
    "changeMin(double)\0changeMax(double)\0"
    "changeMeter(int)\0changeThermoColor1()\0"
    "changeThermoColor2()\0changePipeWith(double)\0"
    "changeAlarmThermoColor1()\0"
    "changeAlarmThermoColor2()\0"
    "enableThermoAlarm(int)\0"
    "changeThermoColorType(int)\0"
    "changeAlarmLevel(double)\0"
    "changeThermoDirection(int)\0"
    "changeNeedleColor()\0changeLcdFont()\0"
    "changeLcdPrecision(double)\0"
    "changeLcdFormat(int)\0"
};

void QRL_MetersManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        QRL_MetersManager *_t = static_cast<QRL_MetersManager *>(_o);
        switch (_id) {
        case 0: _t->refresh(); break;
        case 1: _t->showMeter((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 2: _t->showMeterOptions((*reinterpret_cast< QListWidgetItem*(*)>(_a[1]))); break;
        case 3: _t->showMeterOptions((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 4: _t->changeRefreshRate((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 5: _t->changeMin((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 6: _t->changeMax((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 7: _t->changeMeter((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 8: _t->changeThermoColor1(); break;
        case 9: _t->changeThermoColor2(); break;
        case 10: _t->changePipeWith((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 11: _t->changeAlarmThermoColor1(); break;
        case 12: _t->changeAlarmThermoColor2(); break;
        case 13: _t->enableThermoAlarm((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 14: _t->changeThermoColorType((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 15: _t->changeAlarmLevel((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 16: _t->changeThermoDirection((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 17: _t->changeNeedleColor(); break;
        case 18: _t->changeLcdFont(); break;
        case 19: _t->changeLcdPrecision((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 20: _t->changeLcdFormat((*reinterpret_cast< int(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData QRL_MetersManager::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject QRL_MetersManager::staticMetaObject = {
    { &QDialog::staticMetaObject, qt_meta_stringdata_QRL_MetersManager,
      qt_meta_data_QRL_MetersManager, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &QRL_MetersManager::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *QRL_MetersManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *QRL_MetersManager::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_QRL_MetersManager))
        return static_cast<void*>(const_cast< QRL_MetersManager*>(this));
    return QDialog::qt_metacast(_clname);
}

int QRL_MetersManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QDialog::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 21)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 21;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
