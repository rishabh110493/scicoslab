/****************************************************************************
** Meta object code from reading C++ file 'targets_manager.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.6)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/targets_manager.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'targets_manager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.6. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_QRL_TargetsManager[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       9,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       4,       // signalCount

 // signals: signature, parameters, type, tag, flags
      20,   19,   19,   19, 0x05,
      34,   19,   19,   19, 0x05,
      47,   19,   19,   19, 0x05,
      65,   19,   19,   19, 0x05,

 // slots: signature, parameters, type, tag, flags
      88,   19,   19,   19, 0x09,
      96,   19,   19,   19, 0x09,
     103,   19,   19,   19, 0x09,
     119,   19,   19,   19, 0x09,
     138,   19,   19,   19, 0x09,

       0        // eod
};

static const char qt_meta_stringdata_QRL_TargetsManager[] = {
    "QRL_TargetsManager\0\0startTarget()\0"
    "stopTarget()\0connectToTarget()\0"
    "disconnectFromTarget()\0start()\0stop()\0"
    "connectTarget()\0disconnectTarget()\0"
    "hrtModusChanged(int)\0"
};

void QRL_TargetsManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        QRL_TargetsManager *_t = static_cast<QRL_TargetsManager *>(_o);
        switch (_id) {
        case 0: _t->startTarget(); break;
        case 1: _t->stopTarget(); break;
        case 2: _t->connectToTarget(); break;
        case 3: _t->disconnectFromTarget(); break;
        case 4: _t->start(); break;
        case 5: _t->stop(); break;
        case 6: _t->connectTarget(); break;
        case 7: _t->disconnectTarget(); break;
        case 8: _t->hrtModusChanged((*reinterpret_cast< int(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData QRL_TargetsManager::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject QRL_TargetsManager::staticMetaObject = {
    { &QDialog::staticMetaObject, qt_meta_stringdata_QRL_TargetsManager,
      qt_meta_data_QRL_TargetsManager, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &QRL_TargetsManager::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *QRL_TargetsManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *QRL_TargetsManager::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_QRL_TargetsManager))
        return static_cast<void*>(const_cast< QRL_TargetsManager*>(this));
    return QDialog::qt_metacast(_clname);
}

int QRL_TargetsManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QDialog::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 9)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 9;
    }
    return _id;
}

// SIGNAL 0
void QRL_TargetsManager::startTarget()
{
    QMetaObject::activate(this, &staticMetaObject, 0, 0);
}

// SIGNAL 1
void QRL_TargetsManager::stopTarget()
{
    QMetaObject::activate(this, &staticMetaObject, 1, 0);
}

// SIGNAL 2
void QRL_TargetsManager::connectToTarget()
{
    QMetaObject::activate(this, &staticMetaObject, 2, 0);
}

// SIGNAL 3
void QRL_TargetsManager::disconnectFromTarget()
{
    QMetaObject::activate(this, &staticMetaObject, 3, 0);
}
QT_END_MOC_NAMESPACE
