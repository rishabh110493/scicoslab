/****************************************************************************
** Meta object code from reading C++ file 'main_window.h'
**
** Created by: The Qt Meta Object Compiler version 63 (Qt 4.8.6)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../src/main_window.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'main_window.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.6. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_QRL_MainWindow[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
      22,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: signature, parameters, type, tag, flags
      16,   15,   15,   15, 0x0a,
      41,   32,   15,   15, 0x0a,
      63,   32,   15,   15, 0x0a,
     109,   88,   15,   15, 0x0a,
     169,  139,   15,   15, 0x0a,
     222,  203,   15,   15, 0x0a,
     250,  139,   15,   15, 0x0a,
     282,   15,   15,   15, 0x09,
     290,   15,   15,   15, 0x09,
     309,   15,   15,   15, 0x09,
     323,   15,   15,   15, 0x09,
     337,   15,   15,   15, 0x09,
     345,   15,   15,   15, 0x09,
     354,  352,   15,   15, 0x09,
     385,   15,   15,   15, 0x09,
     408,   15,   15,   15, 0x09,
     428,   15,   15,   15, 0x09,
     448,   15,   15,   15, 0x09,
     466,   15,   15,   15, 0x09,
     484,   15,   15,   15, 0x09,
     505,   15,   15,   15, 0x09,
     529,   15,   15,   15, 0x09,

       0        // eod
};

static const char qt_meta_stringdata_QRL_MainWindow[] = {
    "QRL_MainWindow\0\0connectDialog()\0"
    "filename\0loadProfile(QString&)\0"
    "loadParameters(QString&)\0ScopeNumber,filename\0"
    "setScopeFileName(int,QString)\0"
    "ScopeNumber,savetime,autosave\0"
    "setScopeSaveTime(int,double,bool)\0"
    "LogNumber,filename\0setLogFileName(int,QString)\0"
    "setLogSaveTime(int,double,bool)\0about()\0"
    "disconnectDialog()\0loadProfile()\0"
    "saveProfile()\0start()\0stop()\0p\0"
    "connectToTarget(Preferences_T)\0"
    "disconnectFromTarget()\0showMetersManager()\0"
    "showScopesManager()\0showLedsManager()\0"
    "showLogsManager()\0showTargetsManager()\0"
    "showParametersManager()\0"
    "setStatusBarMessage(QString)\0"
};

void QRL_MainWindow::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        QRL_MainWindow *_t = static_cast<QRL_MainWindow *>(_o);
        switch (_id) {
        case 0: _t->connectDialog(); break;
        case 1: _t->loadProfile((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 2: _t->loadParameters((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 3: _t->setScopeFileName((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2]))); break;
        case 4: _t->setScopeSaveTime((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< double(*)>(_a[2])),(*reinterpret_cast< bool(*)>(_a[3]))); break;
        case 5: _t->setLogFileName((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< const QString(*)>(_a[2]))); break;
        case 6: _t->setLogSaveTime((*reinterpret_cast< int(*)>(_a[1])),(*reinterpret_cast< double(*)>(_a[2])),(*reinterpret_cast< bool(*)>(_a[3]))); break;
        case 7: _t->about(); break;
        case 8: _t->disconnectDialog(); break;
        case 9: _t->loadProfile(); break;
        case 10: _t->saveProfile(); break;
        case 11: _t->start(); break;
        case 12: _t->stop(); break;
        case 13: _t->connectToTarget((*reinterpret_cast< Preferences_T(*)>(_a[1]))); break;
        case 14: _t->disconnectFromTarget(); break;
        case 15: _t->showMetersManager(); break;
        case 16: _t->showScopesManager(); break;
        case 17: _t->showLedsManager(); break;
        case 18: _t->showLogsManager(); break;
        case 19: _t->showTargetsManager(); break;
        case 20: _t->showParametersManager(); break;
        case 21: _t->setStatusBarMessage((*reinterpret_cast< const QString(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData QRL_MainWindow::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject QRL_MainWindow::staticMetaObject = {
    { &QMainWindow::staticMetaObject, qt_meta_stringdata_QRL_MainWindow,
      qt_meta_data_QRL_MainWindow, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &QRL_MainWindow::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *QRL_MainWindow::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *QRL_MainWindow::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_QRL_MainWindow))
        return static_cast<void*>(const_cast< QRL_MainWindow*>(this));
    return QMainWindow::qt_metacast(_clname);
}

int QRL_MainWindow::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QMainWindow::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 22)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 22;
    }
    return _id;
}
QT_END_MOC_NAMESPACE
