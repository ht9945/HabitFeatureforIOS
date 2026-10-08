
# Alışkanlık Uygulaması: DesignKitForIOS ve HabitFeature Kullanım Rehberi

Hazırlayan: Claude · 8 Ekim 2026 · Hasan için

## 1. Genel bakış

İki Swift paketi birlikte çalışır. Her paketin kendi Git deposu ve kendi sürüm etiketleri vardır.

| Paket | GitHub deposu | İçeriği |
| --- | --- | --- |
| DesignKitForIOS | ht9945/DesignKitForIOS | Tema, renkler ve genel bileşenler. Alışkanlık konusunu bilmez. |
| HabitFeature | ht9945/HabitFeatureforIOS | Alışkanlık ekranları, view model'ler, veri protokolleri ve örnek veri. DesignKitForIOS'a bağlıdır. |

Bağımlılık yönü: Uygulama → HabitFeature → DesignKitForIOS. Uygulama iki paketi de doğrudan import eder. Depo adı HabitFeatureforIOS olsa da paketin ürün adı HabitFeature'dır, kodda `import HabitFeature` yazılır.

Sorumluluk dağılımı:

- **Paketler:** görünüm, ekran davranışı, veri protokolleri.
- **Uygulama:** giriş noktası, sekmeler ve gezinme, gerçek veri (backend) bağlantısı, kimlik doğrulama, bildirimler, projeye özel tema.

## 2. Gereksinimler

- Xcode 15 veya üstü, Swift 5.9.
- Uygulamanın Deployment Target değeri iOS 17 veya üstü. Paketler Observation, ContentUnavailableView ve Swift Charts kullanır.
- Depolar private ise Xcode > Settings > Accounts altında GitHub hesabı ekli olmalı.

## 3. Yeni projeye kurulum

1. Uygulama projesini Xcode'da aç.
2. Sol panelde mavi proje simgesine tıkla. PROJECT altında proje adını seç ve Package Dependencies sekmesine geç.
3. Alttaki + düğmesine bas ve adresleri sırayla ekle:
   - `https://github.com/ht9945/DesignKitForIOS.git`
   - `https://github.com/ht9945/HabitFeatureforIOS.git`
4. Sürüm kuralı olarak **Up to Next Minor Version** seç (0.x sürümlerinde yeni minör sürüm uyumsuz olabilir). Başlangıç değerleri: DesignKitForIOS 0.6.0, HabitFeature 0.5.0.
5. Ürün seçiminde `DesignKitForIOS` ve `HabitFeature` ürünlerini uygulama hedefine ekle.
6. TARGETS altında uygulamayı seç, General sekmesindeki Frameworks, Libraries, and Embedded Content bölümünde iki ürünün göründüğünü kontrol et.
7. Paketleri kullanan her Swift dosyasının başına gerektiği kadar `import DesignKitForIOS` ve `import HabitFeature` yaz.

Paketler yerel klasör olarak (Add Local) eklenmemeli. Yerel klasör yalnızca geliştirme sırasında geçici kullanılır (Bölüm 10).

## 4. Uygulamada oluşturacağın dosyalar

Paketler ekranları sağlar, uygulamanın iskeletini sen kurarsın. Önerilen yapı:

```
MyHabitApp/
├── MyHabitAppApp.swift       @main, giriş noktası
├── App/
│   ├── HabitBackend.swift    veri protokollerini tek isimde toplar
│   ├── RootView.swift        sekmeler ve view model'ler
│   ├── TodayHost.swift       Bugün, detay ve ekleme gezinmesi
│   ├── SettingsView.swift    uygulamaya özel ayarlar ekranı
│   └── AppTheme.swift        projeye özel tema (isteğe bağlı)
├── Data/
│   └── APIHabitProvider.swift   backend bağlantısı (Bölüm 6)
└── Assets.xcassets           uygulama ikonu, uygulamaya özel renkler
```

Aşağıdaki dosya adları örnektir, uygulamanın adına göre değiştir.

## 5. Dosya dosya kod

### 5.1 App/HabitBackend.swift

HabitFeature üç ayrı veri protokolü tanımlar. Tek bir sınıf üçünü de uygulayabilsin diye uygulamada tek bir isimde birleştirilir.

```swift
import HabitFeature

typealias HabitBackend = HabitProviding & StatsProviding & HabitDetailProviding
```

### 5.2 MyHabitAppApp.swift

Başlangıçta örnek veri (MockHabitProvider) kullanılır. Backend hazır olunca tek satır değişir.

```swift
import SwiftUI
import DesignKitForIOS
import HabitFeature

@main
struct MyHabitAppApp: App {
    private let backend: any HabitBackend = MockHabitProvider()

    var body: some Scene {
        WindowGroup {
            RootView(backend: backend)
                .environment(\.theme, .app)   // tema özelleştirmesi, AppTheme.swift
        }
    }
}
```

Tema özelleştirmesi kullanmayacaksan `.environment` satırını sil, varsayılan tema geçerli olur.

### 5.3 App/RootView.swift

View model'ler burada oluşturulur. Böylece iPad'de kenar çubuğunda sekme değiştirince durum kaybolmaz.

```swift
import SwiftUI
import DesignKitForIOS
import HabitFeature

@MainActor
struct RootView: View {
    private let backend: any HabitBackend
    @State private var selection = "today"
    @State private var todayVM: TodayViewModel
    @State private var statsVM: StatsViewModel

    private let tabs = [
        ShellTab(id: "today", title: "Bugün", systemImage: "checkmark.circle"),
        ShellTab(id: "stats", title: "İstatistik", systemImage: "chart.bar"),
        ShellTab(id: "settings", title: "Ayarlar", systemImage: "gearshape")
    ]

    init(backend: any HabitBackend) {
        self.backend = backend
        _todayVM = State(initialValue: TodayViewModel(provider: backend))
        _statsVM = State(initialValue: StatsViewModel(provider: backend))
    }

    var body: some View {
        AppShell(tabs: tabs, selection: $selection) { tab in
            switch tab.id {
            case "today": TodayHost(backend: backend, todayVM: todayVM)
            case "stats": StatsView(viewModel: statsVM)
            default: SettingsView()
            }
        }
    }
}
```

AppShell iPhone'da alt sekme çubuğu, iPad'de kenar çubuğu çizer. Sekme listesi ve içerik uygulamaya aittir.

### 5.4 App/TodayHost.swift

Gezinme paketin içinde değil uygulamadadır. TodayView yalnızca satıra dokunulduğunu ve ekle düğmesine basıldığını bildirir.

```swift
import SwiftUI
import HabitFeature

@MainActor
struct TodayHost: View {
    let backend: any HabitBackend
    let todayVM: TodayViewModel
    @State private var showAdd = false
    @State private var selected: HabitItem?

    var body: some View {
        NavigationStack {
            TodayView(viewModel: todayVM,
                      onAdd: { showAdd = true },
                      onSelect: { selected = $0 })
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(item: $selected) { habit in
                    HabitDetailView(viewModel: HabitDetailViewModel(
                        habit: habit,
                        provider: backend,
                        onCompleted: { todayVM.setDone($0, to: true) }
                    ))
                }
        }
        .sheet(isPresented: $showAdd) {
            AddHabitView(
                viewModel: AddHabitViewModel(provider: backend) { todayVM.didAdd($0) },
                onClose: { showAdd = false }
            )
        }
    }
}
```

### 5.5 App/SettingsView.swift

Ayarlar ekranı projeye özeldir (hesap, bildirimler, tema seçimi vb.). Başlangıç için DesignKitForIOS bileşenleriyle boş bir ekran yeterlidir.

```swift
import SwiftUI
import DesignKitForIOS

struct SettingsView: View {
    @Environment(\.theme) private var theme

    var body: some View {
        Text("Ayarlar")
            .font(.system(size: 34, weight: .heavy, design: .rounded))
            .foregroundStyle(theme.textPrimary)
    }
}
```

### 5.6 App/AppTheme.swift (isteğe bağlı)

Paketi değiştirmeden projeye özel renk ve köşe yuvarlaklığı vermek için kullanılır.

```swift
import SwiftUI
import DesignKitForIOS

extension Theme {
    static var app: Theme {
        var theme = Theme.default
        theme.accent = Color("BrandAccent")   // uygulamanın kendi Assets.xcassets dosyasında tanımlı olmalı
        theme.cornerRadius = 24
        return theme
    }
}
```

`BrandAccent` adlı renk uygulamanın kendi katalogunda yoksa o satırı sil ya da kataloga ekle. Theme içindeki tüm alanlar değiştirilebilir: accent, background, card, textPrimary, textSecondary, track, cornerRadius.

## 6. Gerçek veri: backend bağlantısı

Ekranlar backend'i bilmez, yalnızca protokolleri tanır. Gerçek veri için protokolleri uygulayan bir sınıf yazılır ve uygulamanın giriş noktasında MockHabitProvider yerine verilir.

| Protokol | Gerekli fonksiyonlar | Hangi ekran kullanır |
| --- | --- | --- |
| HabitProviding | loadToday, setDone(*:for:), add(*:) | Bugün, Alışkanlık ekle, Detay (tamamlama) |
| StatsProviding | loadStats(for:) | İstatistik |
| HabitDetailProviding | loadDetail(for:) | Detay |

Aşağıdaki iskelette rota adları **örnektir**. web\_backend\_pg'deki gerçek rotalara ve JSON biçimine göre uyarlanmalıdır. `baseURL` mutlaka `/` ile bitmeli.

```swift
import Foundation
import HabitFeature

struct APIHabitProvider: HabitBackend {
    let baseURL: URL                       // örn. https://api.ornek.com/
    let tokenProvider: @Sendable () -> String?

    func loadToday() async throws -> [HabitItem] {
        try decode(try await send("GET", "habits/today"))
    }

    func setDone(_ isDone: Bool, for id: HabitItem.ID) async throws {
        _ = try await send("PUT", "habits/" + id.uuidString + "/completion",
                           body: ["done": isDone])
    }

    func add(_ draft: HabitDraft) async throws -> HabitItem {
        try decode(try await send("POST", "habits", body: DraftBody(draft)))
    }

    func loadStats(for range: StatsRange) async throws -> StatsSnapshot {
        let dto: StatsDTO = try decode(try await send("GET", "stats?range=" + range.rawValue))
        return dto.model
    }

    func loadDetail(for id: HabitItem.ID) async throws -> HabitDetail {
        let dto: DetailDTO = try decode(try await send("GET", "habits/" + id.uuidString + "/detail"))
        return dto.model
    }

    // MARK: - Ağ yardımcıları

    private func send(_ method: String, _ path: String,
                      body: (any Encodable)? = nil) async throws -> Data {
        guard let url = URL(string: path, relativeTo: baseURL) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = tokenProvider() {
            request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        }
        if let body { request.httpBody = try JSONEncoder.api.encode(body) }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }
        return data
    }

    private func decode<T: Decodable>(_ data: Data) throws -> T {
        try JSONDecoder.api.decode(T.self, from: data)
    }
}

extension JSONEncoder {
    static var api: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension JSONDecoder {
    static var api: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

// MARK: - Sunucu cevaplarını paket modellerine çeviren yapılar

private struct DraftBody: Encodable {
    let name: String, color: String, recurrence: String
    let days: [Int], goal: Int, goalUnit: String
    let reminderEnabled: Bool, reminderTime: Date

    init(_ d: HabitDraft) {
        name = d.name; color = d.color.rawValue; recurrence = d.recurrence.rawValue
        days = d.days.sorted(); goal = d.goal; goalUnit = d.goalUnit
        reminderEnabled = d.reminderEnabled; reminderTime = d.reminderTime
    }
}

private struct StatsDTO: Decodable {
    struct Point: Decodable { let date: Date; let ratio: Double }
    struct Habit: Decodable { let id: UUID; let title: String; let color: HabitColor; let ratio: Double }
    let completionRate: Double, bestStreak: Int, perfectDays: Int
    let points: [Point], habits: [Habit]

    var model: StatsSnapshot {
        StatsSnapshot(
            completionRate: completionRate, bestStreak: bestStreak, perfectDays: perfectDays,
            points: points.map { CompletionPoint(date: $0.date, ratio: $0.ratio) },
            habits: habits.map { HabitCompletion(id: $0.id, title: $0.title, color: $0.color, ratio: $0.ratio) }
        )
    }
}

private struct DetailDTO: Decodable {
    struct Day: Decodable { let label: String; let isDone: Bool }
    let bestStreak: Int, totalDays: Int
    let week: [Day]

    var model: HabitDetail {
        HabitDetail(bestStreak: bestStreak, totalDays: totalDays,
                    week: week.map { WeekDayStatus(label: $0.label, isDone: $0.isDone) })
    }
}
```

Kullanım (MyHabitAppApp.swift içinde):

```swift
private let backend: any HabitBackend = APIHabitProvider(
    baseURL: URL(string: "https://api.ornek.com/")!,
    tokenProvider: { nil }          // giriş sonrası token'ı buradan ver
)
```

Notlar:

- `HabitItem` Codable'dır. Sunucu `id` (UUID metni), `title`, `subtitle`, `color` (green, orange, blue, purple, red), `streak`, `isDone` alanlarını gönderirse doğrudan çözülür.
- Tarihler ISO 8601 biçiminde beklenir.
- Hata durumunda ekranlar kendi uyarısını gösterir. Protokol fonksiyonlarında hata fırlatman yeterlidir.
- Token saklama ve giriş akışı uygulamanın işidir, paketlerde yoktur.

## 7. DesignKitForIOS bileşen kataloğu

| Bileşen | Kullanım | Not |
| --- | --- | --- |
| Theme | `Theme.default`, `@Environment(\.theme)` | Renkler paketin Colors.xcassets dosyasından gelir (açık ve koyu). |
| PrimaryButtonStyle | `.buttonStyle(.primary)` | Tam genişlik, kapsül biçim, pasifken soluk. |
| ProgressRing | `ProgressRing(progress: 0.5, lineWidth: 10, foreground: nil, track: nil)` | Renk verilmezse tema vurgu rengi. |
| HabitRow | `HabitRow(title:subtitle:color:trailingText:isDone:)` | isDone bir Binding. Yuvarlak buton tamamlamayı değiştirir. |
| StatCard | `StatCard(value: "%71", label: "tamamlama")` | Büyük sayı ve altında açıklama. |
| WeekStrip | `WeekStrip(days: [WeekStrip.Day(label:isDone:)], circleSize: 44)` | Haftanın günlerini daire olarak çizer. |
| card() | `view.card()` | Tema kart rengi ve köşe yuvarlaklığı. |
| ShellTab, AppShell | `AppShell(tabs:selection:content:)` | iPhone'da TabView, iPad'de NavigationSplitView. |
| CounterStepper | `CounterStepper(title:unit:value:range:)` | Yuvarlak artı ve eksi düğmeli sayaç. |
| DaySelector | `DaySelector(labels:selection:)` | selection bir `Set<Int>` Binding. 0 Pazartesi. |
| ColorSwatchPicker, Swatch | `ColorSwatchPicker(swatches:selection:)` | Seçim, Swatch id değeriyle tutulur. |

Tüm bileşenlerin `init` fonksiyonları `public` tanımlıdır. Yeni bileşen eklerken paket dışına açılacak her tür, init ve özellik `public` olmalıdır.

## 8. HabitFeature kataloğu

| Ekran | View model | Veri protokolü | Uygulamaya bildirdikleri |
| --- | --- | --- | --- |
| TodayView | TodayViewModel(provider:) | HabitProviding | onAdd, onSelect(HabitItem) |
| AddHabitView | AddHabitViewModel(provider:onSaved:) | HabitProviding | onClose |
| StatsView | StatsViewModel(provider:) | StatsProviding | yok |
| HabitDetailView | HabitDetailViewModel(habit:provider:onCompleted:) | HabitProviding ve HabitDetailProviding | onCompleted(id) |

Modeller: `HabitItem`, `HabitColor` (green, orange, blue, purple, red), `HabitDraft`, `StatsRange` (week, month, year), `CompletionPoint`, `HabitCompletion`, `StatsSnapshot`, `HabitDetail`, `WeekDayStatus`.

Örnek veri: `MockHabitProvider(habits:)` ve `MockHabitProvider.samples`. Önizleme ve ilk denemeler içindir, kalıcı değildir.

TodayViewModel yardımcıları: `load()`, `toggle(_:)`, `didAdd(_:)`, `setDone(_:to:)`. Detay ekranında tamamlama yapılınca listeyi güncellemek için `setDone` kullanılır.

## 9. Projeye özel değişiklik yolları

Güçten zayıfa, önce en hafif yolu dene:

1. **Parametre veya protokol:** Veri kaynağı, gezinme ve butonların işlevi zaten dışarıdan verilir. Çoğu proje farkı burada çözülür.
2. **Tema:** Renk, köşe yuvarlaklığı gibi görünüm farkları için `Theme` değerlerini uygulamada değiştir (Bölüm 5.6). Tek bir alt görünümde farklı tema istersen o görünüme ayrı `.environment(\.theme, ...)` ver.
3. **Kendi ekranını bileşenlerle kur:** Paketteki ekranlar yetmiyorsa DesignKitForIOS bileşenleriyle uygulamada kendi ekranını yaz ve HabitFeature'ın view model'lerini veya protokollerini kullanmaya devam et.
4. **Ekranı kopyala:** Bir ekranın yapısı çok farklıysa ilgili dosyayı (örneğin TodayView.swift) uygulamaya kopyala, adını değiştir ve orada düzenle. Paketteki sürüm olduğu gibi kalır. Kopyalanan dosyada `public` ve paket içi (`internal`) tür farkına dikkat et.
5. **Pakete yeni özellik ekle:** Değişiklik bütün projelerde işe yarayacaksa paketin kendisini değiştir, sürüm etiketi at ve projelerde güncelle.

Paket içindeki bir tür veya fonksiyon `public` değilse uygulamadan görünmez. Gerekirse pakette `public` yap ve yeni sürüm çıkar.

## 10. Sürümleme ve güncelleme

### Sürüm planı

| DesignKitForIOS | İçeriği |
| --- | --- |
| 0.1.0 | Theme, PrimaryButtonStyle, ProgressRing, HabitRow |
| 0.2.0 | StatCard, WeekStrip, card() |
| 0.3.0 | AppShell |
| 0.4.0 | ProgressRing renk parametreleri, HabitRow trailingText |
| 0.5.0 | CounterStepper, DaySelector, ColorSwatchPicker |
| 0.6.0 | Koyu mod renkleri |

| HabitFeature | İçeriği |
| --- | --- |
| 0.1.0 | TodayView ve veri katmanı |
| 0.2.0 | AddHabitView |
| 0.3.0 | StatsView, DesignKitForIOS 0.5.0 bağımlılığı (URL) |
| 0.4.0 | HabitDetailView |
| 0.5.0 | Koyu mod, DesignKitForIOS 0.6.0 bağımlılığı |

### Etiket atma düzeni

Paket klasöründe, değişiklik bittiğinde:

```bash
git add . && git commit -m "Açıklama"
git tag 0.7.0
git push origin main
git push origin 0.7.0
```

`git push --follow-tags` yalnızca açıklamalı etiketleri gönderir. `git tag 0.7.0` ile atılan hafif etiketler için etiketi adıyla (ya da `git push origin --tags`) göndermek gerekir. Kontrol için `git ls-remote --tags origin`.

### Sıra kuralı

1. Önce DesignKitForIOS değişir, etiketlenir ve GitHub'a gönderilir.
2. Sonra HabitFeature'ın `Package.swift` içindeki `from:` değeri yükseltilir, o da etiketlenir ve gönderilir.
3. En son uygulamada paket sürümleri güncellenir.

HabitFeature yeni bir DesignKitForIOS bileşenini kullanıyorsa `from:` değeri o bileşenin geldiği sürümden düşük olmamalı. Örneğin CounterStepper 0.5.0'da geldi, AddHabitView bunu kullandığı için en az `from: "0.5.0"` gerekir.

`Package.swift` içinde bağımlılık yayımlanan sürümde mutlaka adres olmalı:

```swift
.package(url: "https://github.com/ht9945/DesignKitForIOS.git", from: "0.6.0")
```

`path:` içeren bir sürüm başka projede çözümlenemez. Kontrol: `git show 0.5.0:Package.swift | grep "package("`.

### Uygulamada güncelleme

Xcode'da File > Packages > Update to Latest Package Versions. Sürüm kuralı Up to Next Minor ise yeni minör sürüme (örneğin 0.6.x → 0.7.0) geçmek için Package Dependencies sekmesinde kuralı elle yükseltmen gerekir.

### Geliştirirken yerel klasör

Paketi uygulama içinde canlı değiştirmek için paket klasörünü Finder'dan Xcode proje gezginine sürükle. Aynı kimlikli yerel klasör, adresle eklenmiş paketin önüne geçer. İş bitince klasörü projeden kaldır (dosyaları silmeden), commit ve etiket at.

Bir paket başka bir Xcode penceresinde tek başına açıksa uygulama projesinde aynı paket yüklenemez (already opened uyarısı). İkisini birlikte düzenleyeceksen tek bir workspace kullan.

## 11. Yeni proje kontrol listesi

1. Uygulama projesini iOS 17 veya üstü hedefle oluştur.
2. İki paketi adresle ekle, ürünleri uygulama hedefine bağla (Bölüm 3).
3. HabitBackend.swift, RootView.swift, TodayHost.swift, SettingsView.swift dosyalarını ekle.
4. Giriş noktasında RootView'ı göster.
5. İlk çalıştırmayı MockHabitProvider ile yap, iPhone ve iPad simülatöründe aç.
6. Açık ve koyu temayı Environment Overrides ile kontrol et.
7. İstersen AppTheme.swift ile projeye özel renk ver.
8. APIHabitProvider'ı yaz, giriş noktasında MockHabitProvider yerine ver.
9. Hatırlatıcı bildirimlerini uygulama tarafında ekle (Bölüm 13).

## 12. Sık karşılaşılan hatalar

| Hata mesajı | Neden | Çözüm |
| --- | --- | --- |
| Cannot find type 'X' in scope | Dosya hedef klasöre eklenmemiş ya da import eksik | Dosyanın Sources/PaketAdı altında olduğunu ve `import` satırını kontrol et. |
| Unable to resolve module dependency | Önbellek ya da yanlış ürün/paket adı | Package.swift içinde ürün adlarını kontrol et, `rm -rf .build Package.resolved`, Reset Package Caches, Clean Build Folder. |
| Failed to resolve dependencies, no versions match | İstenen etiket GitHub'da yok | `git ls-remote --tags origin` ile etiketi doğrula, gerekirse `git push origin ETİKET`. |
| Repository not found | Depo yok ya da private ve giriş yapılmamış | Depoyu oluştur, Xcode ve git kimlik bilgilerini kontrol et. |
| Couldn't load ... already opened from another project or workspace | Paket iki pencerede açık | Tek pencere ya da tek workspace kullan. |
| The source must belong to at least one target in the current scheme | Önizlemede yanlış şema seçili | Şema seçicide dosyanın paketini seç, hedefi iPhone simülatörü yap. |
| 'x' is inaccessible due to 'private' protection level | Extension başka dosyada | Extension'ı özelliğin tanımlı olduğu dosyaya taşı. |
| Initializer is inaccessible due to 'internal' protection level | Paket türünün init'i public değil | Pakette `public init` yaz, yeni sürüm çıkar. |
| Color not found (renk görünmüyor) | Katalog adı ya da bundle yanlış | Renk adları birebir aynı olmalı, kodda `bundle: .module` kullanılmalı. |
| 'Everything up-to-date' ama etiketler GitHub'da yok | Hafif etiketler follow-tags ile gitmez | `git push origin --tags`. |

## 13. Sonraki adımlar

- Gerçek veri: APIHabitProvider'ı web\_backend\_pg rotalarıyla tamamla.
- Hatırlatıcı bildirimleri: AddHabitView'daki hatırlatıcı bilgisi şimdilik yalnızca veridir. Uygulamada UNUserNotificationCenter ile izin isteyip bildirimi planlamak gerekir.
- Alışkanlık düzenleme ekranı ve haftalık (haftada X kez) tekrar seçeneği.
- İsteğe bağlı: iPad'e özel yerleşimler ve widget desteği.
