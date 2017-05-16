/****************************************************************************
** Meta object code from reading C++ file 'scope_window.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.6)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/scope_window.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'scope_window.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.6. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_QRL_ScopeWindow[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       3,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
      17,   16,   16,   16, 0x0a,
      29,   27,   16,   16, 0x0a,
      58,   52,   16,   16, 0x09,

       0        // eod
};

static const char qt_meta_stringdata_QRL_ScopeWindow[] = {
    "QRL_ScopeWindow\0\0refresh()\0v\0"
    "setFileVersion(qint32)\0event\0"
    "closeEvent(QCloseEvent*)\0"
};

void QRL_ScopeWindow::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        QRL_ScopeWindow *_t = static_cast<QRL_ScopeWindow *>(_o);
        switch (_id) {
        case 0: _t->refresh(); break;
        case 1: _t->setFileVersion((*reinterpret_cast< qint32(*)>(_a[1]))); break;
        case 2: _t->closeEvent((*reinterpret_cast< QCloseEvent*(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData QRL_ScopeWindow::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject QRL_ScopeWindow::staticMetaObject = {
    { &QDialog::staticMetaObject, qt_meta_stringdata_QRL_ScopeWindow,
      qt_meta_data_QRL_ScopeWindow, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &QRL_ScopeWindow::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *QRL_ScopeWindow::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *QRL_ScopeWindow::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_QRL_ScopeWindow))
        return static_cast<void*>(const_cast< QRL_ScopeWindow*>(this));
    return QDialog::qt_metacast(_clname);
}

int QRL_ScopeWindow::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QDialog::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 3)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 3;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
