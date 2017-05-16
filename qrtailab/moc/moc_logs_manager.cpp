/****************************************************************************
** Meta object code from reading C++ file 'logs_manager.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.6)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/logs_manager.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'logs_manager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.6. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_QRL_LogsManager[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
      23,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
      22,   17,   16,   16, 0x0a,
      55,   16,   16,   16, 0x0a,
      75,   16,   16,   16, 0x0a,
      89,   16,   16,   16, 0x0a,
     102,   16,   16,   16, 0x0a,
     125,   16,   16,   16, 0x0a,
     149,   16,   16,   16, 0x0a,
     159,   16,   16,   16, 0x0a,
     185,   16,   16,   16, 0x0a,
     204,   16,   16,   16, 0x0a,
     217,   16,   16,   16, 0x0a,
     231,   16,   16,   16, 0x0a,
     251,   16,   16,   16, 0x0a,
     273,  271,   16,   16, 0x0a,
     293,   16,   16,   16, 0x0a,
     311,   16,   16,   16, 0x0a,
     334,   16,   16,   16, 0x0a,
     353,   16,   16,   16, 0x0a,
     380,   16,   16,   16, 0x0a,
     405,   16,   16,   16, 0x0a,
     423,   16,   16,   16, 0x0a,
     441,   16,   16,   16, 0x0a,
     463,   16,   16,   16, 0x0a,

       0        // eod
};

static const char qt_meta_stringdata_QRL_LogsManager[] = {
    "QRL_LogsManager\0\0item\0"
    "showLogOptions(QListWidgetItem*)\0"
    "showLogOptions(int)\0startSaving()\0"
    "stopSaving()\0changeSaveTime(double)\0"
    "changeFileName(QString)\0refresh()\0"
    "changeRefreshRate(double)\0setFileDirectory()\0"
    "showLog(int)\0holdPlot(int)\0"
    "setMinScale(double)\0setMaxScale(double)\0"
    "d\0changeDelegate(int)\0setPixelSize(int)\0"
    "setShowItemNumber(int)\0changeLogView(int)\0"
    "changeHistDistance(double)\0"
    "changeHistLength(double)\0changeDx(QString)\0"
    "changeDy(QString)\0changeXOffset(double)\0"
    "changeYOffset(double)\0"
};

void QRL_LogsManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        QRL_LogsManager *_t = static_cast<QRL_LogsManager *>(_o);
        switch (_id) {
        case 0: _t->showLogOptions((*reinterpret_cast< QListWidgetItem*(*)>(_a[1]))); break;
        case 1: _t->showLogOptions((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 2: _t->startSaving(); break;
        case 3: _t->stopSaving(); break;
        case 4: _t->changeSaveTime((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 5: _t->changeFileName((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 6: _t->refresh(); break;
        case 7: _t->changeRefreshRate((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 8: _t->setFileDirectory(); break;
        case 9: _t->showLog((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 10: _t->holdPlot((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 11: _t->setMinScale((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 12: _t->setMaxScale((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 13: _t->changeDelegate((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 14: _t->setPixelSize((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 15: _t->setShowItemNumber((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 16: _t->changeLogView((*reinterpret_cast< int(*)>(_a[1]))); break;
        case 17: _t->changeHistDistance((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 18: _t->changeHistLength((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 19: _t->changeDx((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 20: _t->changeDy((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        case 21: _t->changeXOffset((*reinterpret_cast< double(*)>(_a[1]))); break;
        case 22: _t->changeYOffset((*reinterpret_cast< double(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData QRL_LogsManager::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject QRL_LogsManager::staticMetaObject = {
    { &QDialog::staticMetaObject, qt_meta_stringdata_QRL_LogsManager,
      qt_meta_data_QRL_LogsManager, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &QRL_LogsManager::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *QRL_LogsManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *QRL_LogsManager::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_QRL_LogsManager))
        return static_cast<void*>(const_cast< QRL_LogsManager*>(this));
    return QDialog::qt_metacast(_clname);
}

int QRL_LogsManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QDialog::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 23)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 23;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
