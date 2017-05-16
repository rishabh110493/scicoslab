/****************************************************************************
** Meta object code from reading C++ file 'parameters_manager.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.6)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/parameters_manager.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'parameters_manager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.6. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_QRL_ParametersManager[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
      12,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
      23,   22,   22,   22, 0x0a,
      38,   22,   22,   22, 0x0a,
      58,   22,   22,   22, 0x0a,
      75,   22,   22,   22, 0x0a,
      94,   92,   22,   22, 0x0a,
     125,  120,   22,   22, 0x0a,
     164,  120,   22,   22, 0x0a,
     206,   22,   22,   22, 0x0a,
     225,   22,   22,   22, 0x0a,
     260,  251,   22,   22, 0x0a,
     284,   22,   22,   22, 0x09,
     300,   22,   22,   22, 0x09,

 // enums: name, flags, count, data

 // enum data: key, value

       0        // eod
};

static const char qt_meta_stringdata_QRL_ParametersManager[] = {
    "QRL_ParametersManager\0\0batchMode(int)\0"
    "showAllBlocks(bool)\0showBlocks(bool)\0"
    "hideBlocks(bool)\0t\0changeSearchText(QString)\0"
    "item\0showTunableParameter(QListWidgetItem*)\0"
    "changeTunableParameter(QTableWidgetItem*)\0"
    "uploadParameters()\0downloadBatchParameters()\0"
    "filename\0loadParameter(QString&)\0"
    "loadParameter()\0saveParameter()\0"
};

void QRL_ParametersManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        QRL_ParametersManager *_t = static_cast<QRL_ParametersManager *>(_o);
        switch (_id) {
        case 0: _t->batchMode((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 1: _t->showAllBlocks((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 2: _t->showBlocks((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 3: _t->hideBlocks((*reinterpret_cast< bool(*)>(_a[1]))); break;
        case 4: _t->changeSearchText((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 5: _t->showTunableParameter((*reinterpret_cast< QListWidgetItem*(*)>(_a[1]))); break;
        case 6: _t->changeTunableParameter((*reinterpret_cast< QTableWidgetItem*(*)>(_a[1]))); break;
        case 7: _t->uploadParameters(); break;
        case 8: _t->downloadBatchParameters(); break;
        case 9: _t->loadParameter((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 10: _t->loadParameter(); break;
        case 11: _t->saveParameter(); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData QRL_ParametersManager::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject QRL_ParametersManager::staticMetaObject = {
    { &QDialog::staticMetaObject, qt_meta_stringdata_QRL_ParametersManager,
      qt_meta_data_QRL_ParametersManager, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &QRL_ParametersManager::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *QRL_ParametersManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *QRL_ParametersManager::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_QRL_ParametersManager))
        return static_cast<void*>(const_cast< QRL_ParametersManager*>(this));
    return QDialog::qt_metacast(_clname);
}

int QRL_ParametersManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QDialog::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 12)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 12;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
