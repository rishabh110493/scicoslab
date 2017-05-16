/****************************************************************************
** Meta object code from reading C++ file 'meter_window.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.6)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/meter_window.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'meter_window.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.6. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_QRL_MeterWindow[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       1,   14, // methods
       0,    0, // properties
       1,   19, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
      23,   17,   16,   16, 0x09,

 // enums: name, flags, count, data
      48, 0x0,    3,   23,

 // enum data: key, value
      59, uint(QRL_MeterWindow::THERMO),
      66, uint(QRL_MeterWindow::DIAL),
      71, uint(QRL_MeterWindow::LCD),

       0        // eod
};

static const char qt_meta_stringdata_QRL_MeterWindow[] = {
    "QRL_MeterWindow\0\0event\0closeEvent(QCloseEvent*)\0"
    "Meter_Type\0THERMO\0DIAL\0LCD\0"
};

void QRL_MeterWindow::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        QRL_MeterWindow *_t = static_cast<QRL_MeterWindow *>(_o);
        switch (_id) {
        case 0: _t->closeEvent((*reinterpret_cast< QCloseEvent*(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData QRL_MeterWindow::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject QRL_MeterWindow::staticMetaObject = {
    { &QDialog::staticMetaObject, qt_meta_stringdata_QRL_MeterWindow,
      qt_meta_data_QRL_MeterWindow, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &QRL_MeterWindow::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *QRL_MeterWindow::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *QRL_MeterWindow::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_QRL_MeterWindow))
        return static_cast<void*>(const_cast< QRL_MeterWindow*>(this));
    return QDialog::qt_metacast(_clname);
}

int QRL_MeterWindow::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QDialog::qt_metacall(_c, _id, _a);
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
