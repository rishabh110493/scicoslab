/****************************************************************************
** Meta object code from reading C++ file 'target_thread.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.6)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/target_thread.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'target_thread.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.6. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_TargetThread[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       1,   14, // methods
       0,    0, // properties
       3,   19, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
      14,   13,   13,   13, 0x0a,

 // enums: name, flags, count, data
      22, 0x0,    7,   31,
      35, 0x0,   10,   45,
      44, 0x0,    5,   65,

 // enum data: key, value
      56, uint(TargetThread::PARAMS_MANAGER),
      71, uint(TargetThread::SCOPES_MANAGER),
      86, uint(TargetThread::LOGS_MANAGER),
      99, uint(TargetThread::ALOGS_MANAGER),
     113, uint(TargetThread::LEDS_MANAGER),
     126, uint(TargetThread::METERS_MANAGER),
     141, uint(TargetThread::SYNCHS_MANAGER),
     156, uint(TargetThread::CONNECT_TO_TARGET),
     174, uint(TargetThread::CONNECT_TO_TARGET_WITH_PROFILE),
     205, uint(TargetThread::DISCONNECT_FROM_TARGET),
     228, uint(TargetThread::START_TARGET),
     241, uint(TargetThread::STOP_TARGET),
     253, uint(TargetThread::UPDATE_PARAM),
     266, uint(TargetThread::GET_TARGET_TIME),
     282, uint(TargetThread::BATCH_DOWNLOAD),
     297, uint(TargetThread::GET_PARAMS),
     308, uint(TargetThread::CLOSE),
     314, uint(TargetThread::rt_SCALAR),
     324, uint(TargetThread::rt_VECTOR),
     334, uint(TargetThread::rt_MATRIX_ROW_MAJOR),
     354, uint(TargetThread::rt_MATRIX_COL_MAJOR),
     374, uint(TargetThread::rt_MATRIX_COL_MAJOR_ND),

       0        // eod
};

static const char qt_meta_stringdata_TargetThread[] = {
    "TargetThread\0\0start()\0Manager_Type\0"
    "Commands\0Param_Class\0PARAMS_MANAGER\0"
    "SCOPES_MANAGER\0LOGS_MANAGER\0ALOGS_MANAGER\0"
    "LEDS_MANAGER\0METERS_MANAGER\0SYNCHS_MANAGER\0"
    "CONNECT_TO_TARGET\0CONNECT_TO_TARGET_WITH_PROFILE\0"
    "DISCONNECT_FROM_TARGET\0START_TARGET\0"
    "STOP_TARGET\0UPDATE_PARAM\0GET_TARGET_TIME\0"
    "BATCH_DOWNLOAD\0GET_PARAMS\0CLOSE\0"
    "rt_SCALAR\0rt_VECTOR\0rt_MATRIX_ROW_MAJOR\0"
    "rt_MATRIX_COL_MAJOR\0rt_MATRIX_COL_MAJOR_ND\0"
};

void TargetThread::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        TargetThread *_t = static_cast<TargetThread *>(_o);
        switch (_id) {
        case 0: _t->start(); break;
        default: ;
        }
    }
    Q_UNUSED(_a);
}

const QMetaObjectExtraData TargetThread::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject TargetThread::staticMetaObject = {
    { &QThread::staticMetaObject, qt_meta_stringdata_TargetThread,
      qt_meta_data_TargetThread, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &TargetThread::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *TargetThread::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *TargetThread::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_TargetThread))
        return static_cast<void*>(const_cast< TargetThread*>(this));
    return QThread::qt_metacast(_clname);
}

int TargetThread::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QThread::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 1)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
