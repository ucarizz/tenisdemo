using Microsoft.AspNetCore.Mvc;

namespace TenisApi.Controllers
{
    [ApiController]
    [Route("v1/legal")]
    public class LegalController : ControllerBase
    {
        [HttpGet("kvkk")]
        public IActionResult GetKvkkText()
        {
            var kvkkText = @"# KVKK Aydınlatma Metni

6698 sayılı Kişisel Verilerin Korunması Kanunu (""KVKK"") uyarınca, **TenisDemo** (Bundan sonra ""Uygulama"" olarak anılacaktır) olarak, veri sorumlusu sıfatıyla, kişisel verilerinizi aşağıda açıklanan çerçevede işleyeceğiz.

## 1. Hangi Kişisel Verilerinizi İşliyoruz?
Uygulamamıza kayıt olurken ve uygulamayı kullanırken aşağıdaki kişisel verileriniz işlenmektedir:
- **Kimlik Bilgileri:** Adınız Soyadınız.
- **İletişim Bilgileri:** E-posta adresiniz.
- **İşlem Güvenliği Bilgileri:** Şifreniz (özet değer/hash olarak saklanır) ve oturum token bilgileriniz.
- **Uygulama Kullanım Bilgileri:** Tenis maçı skorlarınız, vuruş (swing) istatistikleriniz ve analizleriniz.

## 2. Kişisel Verilerinizin İşlenme Amaçları
Kişisel verileriniz aşağıdaki amaçlarla işlenmektedir:
- Üyelik kaydının oluşturulması ve hesabınızın doğrulanması.
- Uygulama içi tenis maç sonuçlarının ve istatistiklerinin tutulması, analiz edilmesi.
- Hizmetlerimizin iyileştirilmesi, analizlerin yapılması ve teknik sorunların çözülmesi.
- Yetkili kurum ve kuruluşlara bilgi verilmesi.

## 3. Kişisel Verilerin Toplanma Yöntemi ve Hukuki Sebebi
Kişisel verileriniz, Uygulama üzerinden tamamen otomatik yöntemlerle toplanmakta olup; KVKK Madde 5/2(c) uyarınca **""Bir sözleşmenin kurulması veya ifasıyla doğrudan doğruya ilgili olması kaydıyla, sözleşmenin taraflarına ait kişisel verilerin işlenmesinin gerekli olması""** hukuki sebebine dayanarak işlenmektedir.

## 4. İşlenen Kişisel Verilerin Aktarılması
Kişisel verileriniz yasal yükümlülüklerin yerine getirilmesi amacıyla yetkili kamu kurum ve kuruluşları (adli makamlar, emniyet güçleri vb.) dışında üçüncü şahıslara aktarılmamaktadır.

## 5. Haklarınız (KVKK Madde 11)
Kanun uyarınca kişisel verilerinize ilişkin şu haklara sahipsiniz:
- Kişisel verilerinizin işlenip işlenmediğini öğrenme,
- İşlenmişse bilgi talep etme,
- İşlenme amacını ve amacına uygun kullanılıp kullanılmadığını öğrenme,
- Yurt içinde veya yurt dışında kişisel verilerin aktarıldığı üçüncü kişileri bilme,
- Eksik veya yanlış işlenmişse düzeltilmesini isteme,
- KVKK Madde 7 çerçevesinde verilerin silinmesini veya yok edilmesini isteme (Profilim -> Hesabımı Sil menüsünden bu işlemi gerçekleştirebilirsiniz),
- Düzeltme, silme ve yok etme işlemlerinin verilerin aktarıldığı üçüncü kişilere bildirilmesini isteme.

Sorularınız ve talepleriniz için **destek@tenisdemo.com** e-posta adresi üzerinden bizimle iletişime geçebilirsiniz.";

            return Ok(new { content = kvkkText });
        }
    }
}
